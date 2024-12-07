. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_num_to_binary]++)) && return 0

. ./str/str_ltrim_zeros.sh || return 1

# 任意格式的数字转换成2进制数(不支持8进制)
# 0b110 0x456 0Xab102 456 005678
# :TODO: 高阶函数适配
bit_num_to_binary ()
{
    local - ; set +xv
    local value=${1,,}
    local filed_length=$2
    local filed_char=$3
    local -i value_decimal
    if [[ "${value:0:2}" == '0x' ]] ; then
        printf -v value_decimal "%d" "$value"
    elif [[ "${value:0:2}" == '0b' ]] ; then
        printf -v value_decimal "%d" "$((2#${value:2}))"
    elif [[ "$value" =~ ^[0-9]+$ ]]; then
        # 删除前导0
        str_ltrim_zeros value
        printf -v value_decimal "%s" "$value"
    fi

    local binary="" remainder=

    while ((value_decimal)) ; do
        ((remainder=value_decimal%2))
        binary="${remainder}${binary}"
        ((value_decimal/=2))
    done

    if [[ -n "$filed_length" && -n "$filed_char" ]] ; then
        # :TODO: printf打印字符串前面填充指定数量字符有一步到位的方法吗?
        out_binary_str=$(printf "%0${filed_length}s" "$binary")
        printf "%s" "${out_binary_str// /${filed_char}}"
    else
        printf "%s" "$binary"
    fi
}

return 0

