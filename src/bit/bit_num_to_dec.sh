. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_num_to_dec]++)) && return 0

. ./str/str_ltrim_zeros.sh || return 1

# 任意格式的数字转换成10进制数(不支持8进制)
# 0b110 0x456 0Xab102 456 005678
# :TODO: 高阶函数适配
bit_num_to_dec ()
{
    local value=${1,,}
    if [[ "${value:0:2}" == '0x' ]] ; then
        printf "%d" "$value"
    elif [[ "${value:0:2}" == '0b' ]] ; then
        printf "%d" "$((2#${value:2}))"
    elif [[ "$value" =~ ^[0-9]+$ ]]; then
        # 删除前导0
        str_ltrim_zeros value
        printf "%s" "$value"
    fi
}

return 0

