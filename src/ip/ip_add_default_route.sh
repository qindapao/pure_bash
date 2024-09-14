. ./meta/meta.sh
((DEFENSE_VARIABLES[ip_add_default_route]++)) && return 0

# 1: route 2: nic device port
ip_add_default_route () { ip route add default via "$1" dev "$2" ; }

return 0

