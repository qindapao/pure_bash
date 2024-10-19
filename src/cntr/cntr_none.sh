. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_none]++)) && return 0

. ./cntr/cntr_grep.sh || return 1

cntr_none () { cntr_grep "${@}" none ; }

return 0

