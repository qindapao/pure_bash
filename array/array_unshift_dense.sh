. ./meta/meta.sh
((DEFENSE_VARIABLES[array_unshift_dense]++)) && return 0


# 这个函数也没有用,直接操作更简单
# 把数组都按照稀疏数组处理(添加的元素可以是数组,不能是稀疏数组)t
# 不能处理稀疏数组，效率高，这个函数也是没什么用，直接操作即可
array_unshift_dense ()
{
    local -n _array_unshift_dense_ref_arr="${1}"
    shift
    _array_unshift_dense_ref_arr=("${@}" "${_array_unshift_dense_ref_arr[@]}")
}

return 0

