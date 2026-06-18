addRucioConfig() {
    export RUCIO_CONFIG=@out@/etc/rucio.cfg
}

addEnvHooks "$hostOffset" addRucioConfig
