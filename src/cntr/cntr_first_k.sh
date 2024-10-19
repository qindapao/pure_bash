. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_first_k]++)) && return 0

. ./cntr/cntr_grep.sh || return 1

cntr_first_k () { cntr_grep "${@:1:2}" first_k "${@:3}" ; }

return 0

