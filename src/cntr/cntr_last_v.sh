. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_last_v]++)) && return 0

. ./cntr/cntr_grep.sh || return 1

cntr_last_v () { cntr_grep "${@:1:2}" last_v "${@:3}" ; }

return 0

