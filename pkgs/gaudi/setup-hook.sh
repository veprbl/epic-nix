if [[ "$(uname -s)" = "Darwin" ]] || [[ "$OSTYPE" == "darwin"* ]]; then
	export DYLD_LIBRARY_PATH="@out@/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
else
	export LD_LIBRARY_PATH="@out@/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi
