. ./meta/meta.sh
((DEFENSE_VARIABLES[awk_between]++)) && return 0

awk_between () { awk -F "$1" '{print $2}' | awk -F "$2" '{print $1}' ; }

return 0

