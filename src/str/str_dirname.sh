. ./meta/meta.sh
((DEFENSE_VARIABLES[str_dirname]++)) && return 0


# 获取目录字符串中的当前目录名
# 用于带文件名的字符串
str_dirname ()
{
    local in_str=${2%/*}
    printf "%s" "${in_str##*/}"
}

alias str_dirname_s='str_dirname ""'

return 0

