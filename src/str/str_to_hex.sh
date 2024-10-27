. ./meta/meta.sh
((DEFENSE_VARIABLES[str_to_hex]++)) && return 0

. ./str/str_ltrim_zeros.sh || return 1
. ./str/str_is_uint.sh || return 1
. ./str/str_is_strict_decimal.sh || return 1

# :TODO: $(str_to_hex x str) 会导致结尾换行符被删除
# echo 命令进来会自动加换行符
str_to_hex ()
{
    case "$#" in
    0)
    local ori_str=
    IFS= read -d '' -r ori_str || true
    str_is_uint "${ori_str}" || return 1
    str_ltrim_zeros "ori_str"
    str_is_strict_decimal "$ori_str" || return 1
    printf "0x%x" "${ori_str}" 
    ;;
    1)
    str_is_uint "${!1}" || return
    str_ltrim_zeros "$1"
    str_is_strict_decimal "${!1}" || return 1
    printf -v "$1" "0x%x" "${!1}" 
    ;;
    *)
    eval -- i$1='"$3"'
    str_is_uint "${3}" || return 1
    str_ltrim_zeros "i$1"
    # 这里必须使用临时变量,直接往关联数组中存储数据有风险
    # 主要是中括号中的展开问题
    eval -- str_is_strict_decimal '"${i'$1'}"' || return 1
    eval -- 'printf -v i'$1' "0x%x" "${i'$1'}"' 
    eval -- $1[\$2]='${i'$1'}'
    ;;
    esac
    return 0
}

return 0

