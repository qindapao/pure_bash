. ./meta/meta.sh
((DEFENSE_VARIABLES[str_index_of]++)) && return 0

. ./str/str_common.sh || return 1


# 预留字符串原型(保证原型字符串的长度足够)
# 返回
# ret 外层变量
# 空值的情况(:TODO:是否需要优化?)
# | $1   | $2   | 结果 |
# |------|------|------|
# | null | null | 0    |
# | null | *    | -1   |
# | *    | null | 0    |
#
str_index_of ()
{
    local haystack=$1 needle=$2 count=${3:-1}
    str_common_repeat '*"$needle"' "$count"; local pattern=$ret
    eval -- "local transformed=\${haystack#$pattern}"
    ((ret=${#haystack}-${#transformed}-${#needle},
        ret<0&&(ret=-1),ret>=0))
}

return 0

