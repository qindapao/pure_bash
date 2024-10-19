. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_first_v]++)) && return 0

. ./cntr/cntr_grep.sh || return 1

cntr_first_v () { cntr_grep "${@:1:2}" first_v "${@:3}" ; }

return 0

