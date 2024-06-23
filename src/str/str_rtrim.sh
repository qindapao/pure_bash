. ./meta/meta.sh
((DEFENSE_VARIABLES[str_rtrim]++)) && return 0

# 去掉行尾空白字符
str_rtrim ()
{
    printf "%s" "${1%"${1##*[![:space:]]}"}"
}

return 0

