. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_num_to_hex]++)) && return 0

. ./str/str_ltrim_zeros.sh || return 1

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

return 0

