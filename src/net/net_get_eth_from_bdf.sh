. ./meta/meta.sh
((DEFENSE_VARIABLES[net_get_eth_from_bdf]++)) && return 0

net_get_eth_from_bdf ()
{
    local bdf=$1
    local -a all_eths=()
    local eth_dev get_bdf
    all_eths=($(ip addr show | grep -E "^[0-9]{1,}:" | awk -F ":" '{print $2}' | awk '{print $1}'))

    for eth_dev in "${all_eths[@]}" ; do
        get_bdf=$(ethtool -i "$eth_dev" | grep -i "^bus-info:" | awk -F ":" '{print $NF}')
        if [[ "$get_bdf" == "$bdf" ]] ; then
            printf "%s" "$eth_dev"
            return 0
        fi
    done
    return 1
}

return 0

