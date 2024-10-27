. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_any_wp]++)) && return 0

. ./cntr/cntr_grep.sh || return 1

cntr_any_wp () { cntr_grep "${@:1:2}" any '' "${@:3}" ; }

return 0

