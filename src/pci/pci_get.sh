. ./meta/meta.sh
((DEFENSE_VARIABLES[pci_get]++)) && return 0

# :TODO: 所有的信息都在这个函数处理,通过别名指定不同的调用
# :TODO: 后面是否有必要通过一个关联数组返回所有需要的信息?
pci_get ()
{
    local bus_id=$1
    local get_type=$2

    case $get_type in
    manu|deviceid)
    local lspci_info= manu_info= deviceid=
    lspci_info=$(lspci -n -s "$bus_id")
    ;;&
        manu)
        manu_info=$(echo "$lspci_info" | awk -F ":" '{print $(NF-1)}' | awk '{print $1}')
        printf "%s" "${manu_info,,}"
        ;;
        deviceid)
        deviceid=$(echo "$lspci_info" | awk -F ":" '{print $(NF)}' | awk '{print $1}')
        printf "%s" "${deviceid,,}"
        ;;
    esac
    
    return 0
}

alias pci_get_manu='pci_get "manu"'
alias pci_get_deviceid='pci_get "deviceid"'

return 0

