. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_set_value]++)) && return 0


# 使用方法
# xx=$(bit_set_value "0x34a" '' 0:1 2:0 3:1 4:1 12:1 13:1)
# 最后得到的值是0x335b
bit_set_value ()
{
    local value=${2}
    # 这里shift 2是因为给高阶函数预留的索引号
    shift 2
    local -A bit_info
    local i
    for i in "$@" ; do bit_info["${i%:*}"]="${i##*:}" ; done
    
    # 置1:((value|=(2#10)))    置0:((value&=~(2#10)))
    for i in "${!bit_info[@]}" ; do ((value=((bit_info[$i]<<$i) | (value & (~(0x1<<$i)))))) ; done 
    printf "0x%02x" "$value"
}

alias bit_set_value_s='bit_set_value ""'

return 0

