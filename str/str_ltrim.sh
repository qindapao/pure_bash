. ./meta/meta.sh
((DEFENSE_VARIABLES[str_ltrim]++)) && return 0

# 去掉行首空白字符
str_ltrim ()
{
    printf "%s" "${1#"${1%%[![:space:]]*}"}"
}

return 0

