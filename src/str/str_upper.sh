. ./meta/meta.sh
((DEFENSE_VARIABLES[str_upper]++)) && return 0

# 字符串转换成大写
str_upper ()
{
    printf "%s" "${1^^}"
}

return 0

