. ./meta/meta.sh
((DEFENSE_VARIABLES[str_lower]++)) && return 0

# 字符串转换成小写
str_lower ()
{
    printf "%s" "${2,,}"
}

alias str_lower_s='str_lower ""'

return 0

