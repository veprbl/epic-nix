local oldOpts="-u"
shopt -qo nounset || oldOpts="+u"
set +u
source @out@/bin/thisdd4hep.sh
set "$oldOpts"
