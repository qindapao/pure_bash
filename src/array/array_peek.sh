. ./meta/meta.sh
((DEFENSE_VARIABLES[array_peek]++)) && return 0

# 取数组的第一个元素，但是不删除它(对应 shift)
# 这是考虑稀疏数组的情况,如果是要取索引0,直接arr[0]即可
# 这个函数好像意义也不大,直接${arr[@]:0:1}更简洁直接
array_peek ()
{
    local -n _array_peek_ref_arr=$1
    printf "%s" "${_array_peek_ref_arr[@]:0:1}"
}

return 0

