. ./meta/meta.sh
((DEFENSE_VARIABLES[array_del_elements_dense]++)) && return 0


# 不保留索引,删除后的数组是一个致密数组(稀疏输入进来,也转换成致密数组)
# 1: 需要处理的数组引用
# 2~@: 需要删除的元素的值
array_del_elements_dense ()
{
    local -n _array_del_elements_dense_ref_arr=$1
    local -a _array_del_elements_dense_copy_arr=()
    shift
    local _array_del_elements_delete_value _array_del_elements_delete_arr_value

    for _array_del_elements_delete_value in "${@}" ; do
        _array_del_elements_dense_copy_arr=("${_array_del_elements_dense_ref_arr[@]}")
        _array_del_elements_dense_ref_arr=()
        for _array_del_elements_delete_arr_value in "${_array_del_elements_dense_copy_arr[@]}" ; do
            if [[ "$_array_del_elements_delete_arr_value" != "$_array_del_elements_delete_value" ]] ; then
                _array_del_elements_dense_ref_arr+=("$_array_del_elements_delete_arr_value")
            fi
        done
    done
}

return 0

