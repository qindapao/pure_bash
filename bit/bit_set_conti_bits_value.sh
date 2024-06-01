. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_set_conti_bits_value]++)) && return 0

. ./array/array_max.sh || return 1
. ./array/array_min.sh || return 1
. ./bit/bit_num_to_hex.sh || return 1
. ./bit/bit_set_value.sh || return 1

# 设置连续位的值
# 1: 需要改变bit位的原始值(转换成16进制)
# 2: 高阶函数数组索引(参数留空)
# 3: 域段(支持正向和负向)(取出最小和最大),默认10进制,包括上下两个边界
# 4: 域段需要设置的值(支持2进制 10进制 16进制),统一转换成16进制
# xx=$(bit_set_conti_bits_value "0x34a" '' '7~0' '0b10101010')
# xx=$(bit_set_conti_bits_value "0x34a" '' '0~7' '0b10101010')
# xx=$(bit_set_conti_bits_value "0x34a" '' '0-7' 0x45)
# xx=$(bit_set_conti_bits_value "0x34a" '' '0-7' 0X45)
# xx=$(bit_set_conti_bits_value "0x34a" '' '0-7' 45)
bit_set_conti_bits_value ()
{
    local value="${1,,}"
    local filed="${3}"
    local upper_limit='' lower_limit=''
    local filed_set_value="${4,,}"

    value=$(bit_num_to_hex "$value")
    [[ -z "$value" ]] && return
    
    if [[ "$filed" =~ ^([0-9]+)[^0-9]([0-9]+) ]] ; then
        upper_limit=$(array_max "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}")   
        lower_limit=$(array_min "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}")   
    else
        return
    fi

    filed_set_value=$(bit_num_to_hex "$filed_set_value")
    [[ -z "$filed_set_value" ]] && return

    local i=0
    local -a params_arr=() 
    for((i=lower_limit;i<=upper_limit;i++)) ; do
        params_arr+=("${i}:$(( (filed_set_value>>(i-lower_limit))&1 ))")
    done

    bit_set_value "$value" '' "${params_arr[@]}"
}

return 0

