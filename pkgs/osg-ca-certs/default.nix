{
  lib,
  stdenv,
  osg-ca-certs-src,
  fetchurl,
  fetchFromGitHub,
  openssl,
  perl,
}:

let
  igtfSrc = fetchurl {
    url = "https://dist.eugridpma.info/distribution/igtf/1.144/igtf-policy-installation-bundle-1.144.tar.gz";
    sha256 = "19q4wcdcy2m0b634yqbajqii5k7yz93xnnp8pjvj4zklnc85cl4h";
  };

  cilogonSrc = fetchFromGitHub {
    owner = "cilogon";
    repo = "letsencrypt-certificates";
    rev = "v0.6.0";
    sha256 = "FHIVEUahlzyhrxZ4Dnhfq2A27appaNhP1lXHcrMJk6E=";
  };
in
stdenv.mkDerivation rec {
  pname = "osg-ca-certs";
  version = "1.144";

  src = osg-ca-certs-src;

  nativeBuildInputs = [ openssl perl ];

  dontConfigure = true;

  postPatch = ''
    patchShebangs .
    substituteInPlace mk-index.pl --replace-fail '/usr/bin/openssl' 'openssl'
  '';

  buildPhase = ''
    runHook preBuild

    # Extract the IGTF bundle into the source directory so the build script
    # finds igtf-policy-installation-bundle-<version> next to letsencrypt-certificates.
    tar -xzf "${igtfSrc}" -C .

    # Replace the bundled letsencrypt-certificates directory with a buildable one.
    # The GitHub repo only ships PEMs; the cilogon repo provides the Makefile,
    # signing_policy, and crl_url files for the classic Let's Encrypt roots.
    rm -rf letsencrypt-certificates
    mkdir letsencrypt-certificates

    # Copy all PEMs from the GitHub source (includes new YE/YR certificates).
    cp ${osg-ca-certs-src}/letsencrypt-certificates/*.pem letsencrypt-certificates/

    # Copy metadata files from cilogon for the certs it knows about.
    cp ${cilogonSrc}/*.signing_policy ${cilogonSrc}/*.crl_url letsencrypt-certificates/ 2>/dev/null || true

    # Generate missing signing_policy and crl_url metadata for the remaining
    # Let's Encrypt certificates (E5-R14, ISRG Root X2) so the resulting
    # package matches the upstream OSG distribution as closely as possible.
    for pem in letsencrypt-certificates/*.pem; do
      base=$(basename "$pem" .pem)
      case "$base" in
        lets-encrypt-*)
          if [ ! -f "letsencrypt-certificates/$base.signing_policy" ]; then
            subj=$(openssl x509 -in "$pem" -noout -subject | sed 's/^subject=//' | sed 's|, |/|g')
            subj="/$subj"
            subj_escaped=$(printf '%s' "$subj" | sed "s/'/\\\\'/g")
            printf "access_id_CA   X509    '%s'\n" "$subj_escaped" > "letsencrypt-certificates/$base.signing_policy"
            printf "pos_rights     globus  CA:sign\n" >> "letsencrypt-certificates/$base.signing_policy"
            printf "cond_subjects  globus  '\"/CN=*\"'\n" >> "letsencrypt-certificates/$base.signing_policy"
          fi
          ;;
        isrg-root-x2)
          if [ ! -f "letsencrypt-certificates/$base.signing_policy" ]; then
            subj=$(openssl x509 -in "$pem" -noout -subject | sed 's/^subject=//' | sed 's|, |/|g')
            subj="/$subj"
            subj_escaped=$(printf '%s' "$subj" | sed "s/'/\\\\'/g")
            cond_subjects=""
            # Upstream OSG policy for ISRG Root X2 lists the E5-E9 and R10-R14 intermediates.
            for child in letsencrypt-certificates/lets-encrypt-{e5,e6,r10,r11,e7,e8,e9,r12,r13,r14}.pem; do
              [ -f "$child" ] || continue
              child_subj=$(openssl x509 -in "$child" -noout -subject | sed 's/^subject=//' | sed 's|, |/|g')
              child_subj_escaped=$(printf '%s' "$child_subj" | sed "s/'/\\\\'/g")
              if [ -z "$cond_subjects" ]; then
                cond_subjects="\"/$child_subj_escaped\""
              else
                cond_subjects="$cond_subjects \"/$child_subj_escaped\""
              fi
            done
            printf "access_id_CA   X509    '%s'\n" "$subj_escaped" > "letsencrypt-certificates/$base.signing_policy"
            printf "pos_rights     globus  CA:sign\n" >> "letsencrypt-certificates/$base.signing_policy"
            printf "cond_subjects  globus  '%s'\n" "$cond_subjects" >> "letsencrypt-certificates/$base.signing_policy"
            printf "http://c.lencr.org\n" > "letsencrypt-certificates/$base.crl_url"
          fi
          ;;
      esac
    done

    # Write a Makefile that generates hash symlinks and can run a sanity check.
    # Using c_rehash -compat creates both old- and new-style hash symlinks,
    # matching the upstream OSG distribution which uses old-style hashes.
    # It also mirrors the signing_policy and crl_url links that upstream creates.
    cat > letsencrypt-certificates/Makefile <<'EOF'
all:
	c_rehash -compat .
	for h in *.0; do \
	  base=$$(readlink "$$h" 2>/dev/null | sed 's/\.pem$$//'); \
	  [ -n "$$base" -a -f "$$base.signing_policy" ] && ln -sf "$$base.signing_policy" "$${h%.0}.signing_policy" || true; \
	  [ -n "$$base" -a -f "$$base.crl_url" ] && ln -sf "$$base.crl_url" "$${h%.0}.crl_url" || true; \
	done

check: all
EOF

    export CADIST="$PWD/certificates"
    export IGTF_CERTS_VERSION="${version}"
    export OSG_CERTS_VERSION="${version}"
    export OUR_CERTS_VERSION="${version}NEW"
    export PKG_NAME="osg-ca-certs"

    # Run the OSG build script. It installs IGTF certs, builds the Let's Encrypt
    # dir with make, creates INDEX and cacerts_sha256sum.txt.
    ./build-certificates-dir.sh

    # The OSG RHEL 8 build produces .java-cert copies for every PEM.
    for f in "$CADIST"/*.pem; do
      cp "$f" "$f.java-cert"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"/etc/grid-security/certificates
    mv certificates/* "$out"/etc/grid-security/certificates/
    runHook postInstall
  '';

  meta = with lib; {
    changelog = "https://repo.opensciencegrid.org/cadist/CHANGES";
    description = "OSG CA certificates";
    license = licenses.unfreeRedistributable; # no license specified
    homepage = "https://ca.cilogon.org/";
    maintainers = with maintainers; [ veprbl ];
  };
}
