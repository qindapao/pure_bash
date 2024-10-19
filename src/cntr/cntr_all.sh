. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_all]++)) && return 0

. ./cntr/cntr_grep.sh || return 1

cntr_all () { cntr_grep "${@}" all ; }

return 0

