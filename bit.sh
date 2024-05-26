# 位操作库

# :TODO: 根据业务需求来实现封装,尽量使纯bash实现

. ./meta.sh
((DEFENSE_VARIABLES[bit]++)) && return

. ./str.sh
. ./array.sh

# 任意格式的数字转换成16进制数(不支持8进制)
# 0b110 0x456 0Xab102 456 005678
bit_num_to_hex ()
{
    local value="${1,,}"
    if [[ "${value:0:2}" == 0[xX] ]] ; then
        printf "%s" "$value"
    elif [[ "${value:0:2}" == "0b" ]] ; then
        printf "0x%x" "$((2#${value:2}))"
    elif [[ "$value" =~ ^[0-9]+$ ]]; then
        # 删除前导0
        value=$(str_ltrim_zeros "$value")
        printf "0x%x" "$value"
    fi
}

# 任意格式的数字转换成10进制数(不支持8进制)
# 0b110 0x456 0Xab102 456 005678
bit_num_to_dec ()
{
    local value="${1,,}"
    if [[ "${value:0:2}" == 0[xX] ]] ; then
        printf "%d" "$value"
    elif [[ "${value:0:2}" == "0b" ]] ; then
        printf "%d" "$((2#${value:2}))"
    elif [[ "$value" =~ ^[0-9]+$ ]]; then
        # 删除前导0
        value=$(str_ltrim_zeros "$value")
        printf "%s" "$value"
    fi
}


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

# 获取一个连续域段的值,并指定输出打印格式
# 1: 需要取域段的数()
# 2: 高阶函数数组索引(参数留空)
# 3: 域段(支持正向和负向)(取出最小和最大),默认10进制,包括上下两个边界
# 4: 读取格式(默认输出16进制数)
#       0x: 输出16进制数(默认)
#       0b: 数组2进制数(0b10220)
#       0d: 输出10进制数
bit_get_conti_bits_value ()
{
    local value="${1,,}"
    local filed="${3}"
    local upper_limit='' lower_limit=''
    local out_put_format="${4:-0x}"

    value=$(bit_num_to_hex "$value")
    [[ -z "$value" ]] && return
    
    if [[ "$filed" =~ ^([0-9]+)[^0-9]([0-9]+) ]] ; then
        upper_limit=$(array_max "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}")   
        lower_limit=$(array_min "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}")   
    else
        return
    fi

    local i=0
    local -a bit_str=""
    for((i=upper_limit;i>=lower_limit;i--)) ; do
        bit_str+="$(( (value>>(i-lower_limit))&1 ))"
    done

    case "$out_put_format" in
        0x) printf "0x%x" "$((2#${bit_str}))" ;;
        0b) printf "0b%s" "${bit_str}" ;;
        0d) printf "%d" "$((2#${bit_str}))" ;;
    esac
}


# pmbus协议下的crc8码计算函数(不可用于高阶函数)
# @ 需要计算crc8的数组(这里不是引用,直接传递内容)
bit_pec_crc8_calculate ()
{
    local data=("$@")
    local i=0 pec=0
    local pec_128_r="" pec_64_r=""
    
    for((i=0;i<${#data[@]};i++)) ; do
        pec=$[${data[i]}^pec]
        ((pec_128_r=(pec&128 > 0)? 9 : 0))
        ((pec_64_r=(pec&64 > 0)? 7 : 0))
        
        pec=$[pec^(pec<<1)^(pec<<2)^pec_128_r^pec_64_r]
    done
    
    printf "0x%x" "$[pec&255]"
}

# 使用方法
# xx=$(bit_set_value "0x34a" '' 0:1 2:0 3:1 4:1 12:1 13:1)
# 最后得到的值是0x335b
bit_set_value ()
{
    local value="${1}"
    # 这里shift 2是因为给高阶函数预留的索引号
    shift 2
    local -A bit_info
    local i
    for i in "$@" ; do bit_info["${i%:*}"]="${i##*:}" ; done
    
    for i in "${!bit_info[@]}" ; do value=$(( (${bit_info["$i"]} << i) | (value & (~(0x1 << i))) )) ; done
    printf "0x%02x" "$value"
}


