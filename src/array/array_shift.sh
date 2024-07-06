. ./meta/meta.sh
((DEFENSE_VARIABLES[array_shift]++)) && return 0


# 删除数组的第一个元素并且返回,支持稀疏数组与非稀疏
# 使用方法:  array_shift arr_name element
array_shift ()
{
    local -n _array_shift_ref_arr="${1}"
    local -n _array_shift_ref_ret="${2}"
    local array_shift_shift_element=
    local _array_shift_indexs=("${!_array_shift_ref_arr[@]}")
    ((${#_array_shift_indexs[@]})) || return 1
    local _array_shift_first_index=${_array_shift_indexs[0]}
    
    array_shift_shift_element="${_array_shift_ref_arr[_array_shift_first_index]}"
    unset '_array_shift_ref_arr[_array_shift_first_index]'
    local -i _array_shift_i
    local -a _array_shift_new_arr=()
    
    for _array_shift_i in "${!_array_shift_ref_arr[@]}" ; do
        _array_shift_new_arr[_array_shift_i-1]="${_array_shift_ref_arr[_array_shift_i]}"
    done
    
    _array_shift_ref_arr=()

    for _array_shift_i in "${!_array_shift_new_arr[@]}" ; do
        _array_shift_ref_arr[_array_shift_i]="${_array_shift_new_arr[_array_shift_i]}"
    done
    _array_shift_ref_ret="$array_shift_shift_element"
    return 0
}

return 0

