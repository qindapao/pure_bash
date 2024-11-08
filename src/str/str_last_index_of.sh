. ./meta/meta.sh
((DEFENSE_VARIABLES[str_last_index_of]++)) && return 0

. ./str/str_common.sh || return 1

# 预留字符串原型(保证原型字符串的长度足够)
# 返回
# ret 外层变量
# | $1   | $2   | result |
# |------|------|--------|
# | null | null | -1     |
# | null | *    | -1     |
# | *    | null | -1     |
# 目前的情况str_last_index_of 三种边界情况都返回-1表示错误

str_last_index_of ()
{
    local haystack=$1 needle=$2 count=${3:-1}
    str_common_repeat '"$needle"*' "$count"; local pattern=$ret
    eval -- "local transformed=\${haystack%$pattern}"
    if [[ $transformed == "$haystack" ]]; then
        ret=-1
    else
        ret=${#transformed}
    fi
    ((ret>=0))
}

return 0

