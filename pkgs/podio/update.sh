#!/bin/sh

set -ue

URL_PREFIX="https://key4hep.web.cern.ch:443/testFiles/podio/"
PODIO_SRC="$(nix eval .#podio.src.outPath | cut -d\" -f2)"
OUTPUT_FILE=pkgs/podio/test_input_files.nix

echo "{ fetchurl }:" >"$OUTPUT_FILE" 
echo "''" >>"$OUTPUT_FILE"
for f in "$PODIO_SRC"/tests/input_files/*.root.md5; do
	FILENAME="$(basename "${f%%.md5}")"
	HASH=$(cat "$f")
	PREFETCH_HASH="$(nix store prefetch-file --json "$URL_PREFIX$HASH" | jq -r .hash)"
	echo "$FILENAME: $HASH -> $PREFETCH_HASH"
	echo 'ln -s ${fetchurl { name = "'$FILENAME'"; url = "'$URL_PREFIX$HASH'"; hash = "'$PREFETCH_HASH'"; }} ./tests/input_files/'$FILENAME >>"$OUTPUT_FILE"
done
echo "''" >>"$OUTPUT_FILE"
