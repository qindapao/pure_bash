. ./meta/meta.sh
((DEFENSE_VARIABLES[ip_add]++)) && return 0

# 1: ip 2: mask 3: nic device port
ip_add () { ip addr add "${1}/${2}" dev "$3" ; }

return 0

