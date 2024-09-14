. ./meta/meta.sh
((DEFENSE_VARIABLES[ip_promisc]++)) && return 0

ip_promisc ()
{
    local nic_dev=$1
    local switch=$2
    local switch_op
    case "$1" in
    0)  switch_op=off ;;
    1)  switch_op=on ;;
    esac

    ip link set dev "${nic_dev}" promisc "$switch_op"
}

return 0

