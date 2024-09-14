. ./meta/meta.sh
((DEFENSE_VARIABLES[ip_show]++)) && return 0

ip_show () { ip addr show "$1" ; }

return 0

