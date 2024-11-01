. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_none_wp]++)) && return 0

. ./cntr/cntr_grep.sh || return 1

cntr_none_wp () { cntr_grep "${@:1:2}" none '' "${@:3}" ; }

return 0

