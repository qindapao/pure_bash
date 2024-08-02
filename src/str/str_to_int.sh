. ./meta/meta.sh
((DEFENSE_VARIABLES[str_to_int]++)) && return 0

. ./str/str_is_hex.sh || return 1
. ./str/str_is_decimal.sh || return 1
. ./str/str_ltrim_zeros.sh || return 1

# 字符串转换成整形(如果非法转换换成0)
# 只支持16进制字符串和10进制字符串
str_to_int ()
{
    while (($#)) ; do
        if str_is_hex_s "${!1}" ; then
            continue
        elif str_is_decimal_s "${!1}" ; then
            str_ltrim_zeros_s "${!1}" "$1"
        else
            eval "$1=0"
        fi


        shift
    done
}


return 0

