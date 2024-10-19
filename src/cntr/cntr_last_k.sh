. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_last_k]++)) && return 0

. ./cntr/cntr_grep.sh || return 1

cntr_last_k () { cntr_grep "${@:1:2}" last_k "${@:3}" ; }

return 0

