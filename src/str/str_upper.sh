. ./meta/meta.sh
((DEFENSE_VARIABLES[str_upper]++)) && return 0

# 字符串转换成大写
# :TODO: $(str_upper x str1) 进程替换后会丢失掉结尾换行符
# printf -v ?
str_upper ()
{
    printf "%s" "${2^^}"
}

alias str_upper_s='str_upper ""'

return 0

