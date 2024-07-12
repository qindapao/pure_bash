. ./meta/meta.sh
((DEFENSE_VARIABLES[str_ltrim]++)) && return 0

# 去掉行首空白字符
str_ltrim ()
{
    printf "%s" "${2#"${2%%[![:space:]]*}"}"
}

alias str_ltrim_s='str_ltrim ""'

return 0

