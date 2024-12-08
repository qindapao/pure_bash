. ./meta/meta.sh
((DEFENSE_VARIABLES[str_last_index_of]++)) && return 0

. ./atom/atom_func_upstr.sh || return 1
. ./str/str_common.sh || return 1

# 预留字符串原型(保证原型字符串的长度足够)
# 返回
# REPLY 外层变量
# | $1   | $2   | result |
# |------|------|--------|
# | null | null | -1     |
# | null | *    | -1     |
# | *    | null | -1     |
# 目前的情况str_last_index_of 三种边界情况都返回-1表示错误

str_last_index_of ()
{
    local haystack=$1 needle=$2 count=${3:-1}
    local pattern
    atom_func_upstr pattern \
        str_common_repeat '"$needle"*' "$count"

    eval -- "local transformed=\${haystack%$pattern}"
    if [[ $transformed == "$haystack" ]]; then
        REPLY=-1
    else
        REPLY=${#transformed}
    fi
    ((REPLY>=0))
}

return 0

