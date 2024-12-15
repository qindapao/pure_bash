. ./meta/meta.sh
((DEFENSE_VARIABLES[str_q_to_arr]++)) && return 0

# 空格分隔的引用字符串转换成数组
# 1: 转换后的数组的名字
# 2: 引用字符串
str_q_to_arr ()
{
    if [[ -o noglob ]] ; then
        eval ''$1'=('$2')'
    else
        local - ; set -f ; eval ''$1'=('$2')' ; set +f
    fi
}

return 0

