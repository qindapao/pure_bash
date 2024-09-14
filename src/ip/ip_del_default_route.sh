. ./meta/meta.sh
((DEFENSE_VARIABLES[ip_del_default_route]++)) && return 0

ip_del_default_route () { ip route del default ; }

return 0

