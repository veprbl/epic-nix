{ fetchurl }:
''
ln -s ${fetchurl { name = "edm4hep_example_rntuple_v00-99-01_podio_v01-03.root"; url = "https://key4hep.web.cern.ch:443/testFiles/EDM4hep/1e1b8bff26a5983ee7371f0e76584bcc"; hash = "sha256-qcAhPSDBYqKSBYOYKAZTf72NlWiHMcaCYlz13XtNuFA="; }} ./test/backwards_compat/input_files/edm4hep_example_rntuple_v00-99-01_podio_v01-03.root
ln -s ${fetchurl { name = "edm4hep_example_v00-99-01_podio_v01-01.root"; url = "https://key4hep.web.cern.ch:443/testFiles/EDM4hep/bd4006fb7a56fa765ede88c2920eb351"; hash = "sha256-oLdVVjefQN7NdOQTMSMpk23+idhC0+XNAXnMNSSQ1Vw="; }} ./test/backwards_compat/input_files/edm4hep_example_v00-99-01_podio_v01-01.root
''
