. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_int]++)) && return 0

. ./str/str_is_hex.sh || return 1
. ./str/str_is_decimal.sh || return 1

str_is_int ()
{
    # 这个函数认可10进制前的前导0
    str_is_hex_s "$2" || str_is_decimal_s "$2"
}

alias str_is_int_s='str_is_int ""'

return 0

