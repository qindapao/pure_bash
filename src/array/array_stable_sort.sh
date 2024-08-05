. ./meta/meta.sh
((DEFENSE_VARIABLES[array_stable_sort]++)) && return 0

. ./str/str_to_array.sh || return 1

# 1: 排序数组名字(也可以是普通字符串)
# 2: 排序分隔符
# 3~@: sort的排序列和排序规则
#   -k1,1n 表示按照第一列的自然数排序
#   -k2,2n 表示按照第二列的自然数排序(在第一列相同的情况下)
# 当前只支持同列对比,默认数组中没有换行符
array_stable_sort ()
{
    # :TODO: 这里只支持单一分隔符? 
    eval -- '
    str_to_array "'$1'" \
        "$(sort -t"$2" "${@:3}" \
        <<< $(printf "%s\n" "${'$1'[@]}"))" $'\''\n'\''
    '
    return 0
}

return 0

