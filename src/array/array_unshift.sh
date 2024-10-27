. ./meta/meta.sh
((DEFENSE_VARIABLES[array_unshift]++)) && return 0

# 可以处理稀疏数组
# :TODO: 后面要基于eval实现,不用引用变量
array_unshift ()
{
    local -n _array_unshift_ref_arr=$1
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

