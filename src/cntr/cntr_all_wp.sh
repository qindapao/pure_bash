. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_all_wp]++)) && return 0

. ./cntr/cntr_grep.sh || return 1

cntr_all_wp () { cntr_grep "${@:1:2}" all '' "${@:3}" ; }

return 0

