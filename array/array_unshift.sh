. ./meta/meta.sh
((DEFENSE_VARIABLES[array_unshift]++)) && return 0

# 这个函数几乎无用
# 往数组的头部添加元素(添加的元素可以是数组,不能是稀疏数组)
# 命令行参数有大小限制，不能太大
# 可以处理稀疏数组，但是效率不高
array_unshift ()
{
    local -n _array_unshift_ref_arr="${1}"
    shift
    local -a _array_unshift_new_arr=("${@}")
    local -i _array_unshift_i
    local -i _array_unshift_new_arr_cnt=${#_array_unshift_new_arr[@]}
    for _array_unshift_i in "${!_array_unshift_ref_arr[@]}" ; do
        _array_unshift_new_arr[_array_unshift_i+_array_unshift_new_arr_cnt]="${_array_unshift_ref_arr[_array_unshift_i]}"
    done
    
    _array_unshift_ref_arr=()

    for _array_unshift_i in "${!_array_unshift_new_arr[@]}" ; do
        _array_unshift_ref_arr[_array_unshift_i]="${_array_unshift_new_arr[_array_unshift_i]}"
    done
}

return 0

