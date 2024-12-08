. ./meta/meta.sh
((DEFENSE_VARIABLES[str_index_of]++)) && return 0

. ./atom/atom_func_upstr.sh || return 1
. ./str/str_common.sh || return 1


# 预留字符串原型(保证原型字符串的长度足够)
# 返回
# REPLY 外层变量
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
    local pattern
    atom_func_upstr pattern \
        str_common_repeat '*"$needle"' "$count" 

    eval -- "local transformed=\${haystack#$pattern}"
    ((REPLY=${#haystack}-${#transformed}-${#needle},
        REPLY<0&&(REPLY=-1),REPLY>=0))
}

return 0

