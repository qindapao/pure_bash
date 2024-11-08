. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_num_to_hex]++)) && return 0

# :TODO: 数字计算中的语法错误需要处理吗?
# 比如传进来带空格的字符串?
# $(())里面中是会报语法错误的
# 任意格式的数字转换成16进制数(不支持8进制)
# 0b110 0x456 0Xab102 456 005678
# 可用于高阶函数cntr_map
bit_num_to_hex ()
{
    case "$#" in
    0)
    local value=
    IFS= read -d '' -r value || true
    value=${value,,}

    if [[ "${value:0:2}" == '0x' ]] ; then
        printf "%s" "$value"
    elif [[ "${value:0:2}" == '0b' ]] ; then
        printf "0x%x" "$((2#${value:2}))"
    elif [[ "$value" =~ ^[0-9]+$ ]]; then
        # 删除前导0
        # value=$((10#$value))
        # https://mywiki.wooledge.org/ArithmeticExpression
        # 下面这个才能处理负号,虽然这里不处理负号
        printf "0x%x" "$(( ${value%%[!+-]*}10#${value#[-+]} ))"
    fi
    ;;
    1)
    eval -- ''$1'=${!1,,}'
    if [[ "${!1:0:2}" == '0x' ]] ; then
        true
    elif [[ "${!1:0:2}" == '0b' ]] ; then
        printf -v "$1" "0x%x" "$((2#${!1:2}))"
    elif [[ "${!1}" =~ ^[0-9]+$ ]] ; then
        printf -v "$1" "0x%x" "$(( ${!1%%[!+-]*}10#${!1#[-+]} ))"
    fi
    ;;
    *)
    set -- '
        shift
        eA1=${3,,}
        if [[ "${eA1:0:2}" == "0x" ]] ; then
            A1[$2]=${eA1}
        elif [[ "${eA1:0:2}" == "0b" ]] ; then
            printf -v eA1 "0x%x" "$((2#${eA1:2}))"
            A1[$2]=${eA1}
        elif [[ "$eA1" =~ ^[0-9]+$ ]] ; then
            printf -v eA1 "0x%x" "$(( ${eA1%%[!+-]*}10#${eA1#[-+]} ))"
            A1[$2]=${eA1}
        fi
    ' "${@}"
    eval -- "${1//A1/$2}"
    ;;
    esac
}

return 0

