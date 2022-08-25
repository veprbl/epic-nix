export ROOT_INCLUDE_PATH="@out@/include:.:../../common${ROOT_INCLUDE_PATH:+:$ROOT_INCLUDE_PATH}"
if [[ "$(uname -s)" = "Darwin" ]] || [[ "$OSTYPE" == "darwin"* ]]; then
	export DYLD_LIBRARY_PATH="@out@/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
else
	export LD_LIBRARY_PATH="@out@/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi
export CALIBRATIONROOT=@calibrations@
