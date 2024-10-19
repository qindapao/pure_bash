. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_any]++)) && return 0

. ./cntr/cntr_grep.sh || return 1

cntr_any () { cntr_grep "${@}" any ; }

return 0

