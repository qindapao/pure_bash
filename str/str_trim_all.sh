. ./meta/meta.sh
((DEFENSE_VARIABLES[str_trim_all]++)) && return 0

# 去掉行首行尾所有空格，中间的所有空白保留一个空格
# Usage: trim_all "   example   string    "
str_trim_all ()
{
    local deal_str="${1}"
    declare -a str_arr
    read -d "" -ra str_arr < <(printf "%s" "$deal_str")
    deal_str="${str_arr[*]}"
    printf "%s" "$deal_str"
}

return 0

