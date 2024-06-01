. ./meta/meta.sh
((DEFENSE_VARIABLES[array_revert]++)) && return 0


# 保持数组的索引不变
array_revert ()
{
    local -n _array_revert_ref_arr="${1}"
    
    local _array_revert_arr_size="${#_array_revert_ref_arr[@]}"
    ((_array_revert_arr_size)) || return

    local -a _array_revert_tmp_arr=("${_array_revert_ref_arr[@]}")
    local -a _array_revert_indexs=("${!_array_revert_ref_arr[@]}")

    local _array_revert_index

    for((_array_revert_index=0;_array_revert_index<_array_revert_arr_size;_array_revert_index++)) ; do
        _array_revert_ref_arr[${_array_revert_indexs[_array_revert_index]}]="${_array_revert_tmp_arr[_array_revert_arr_size-_array_revert_index-1]}"
    done
}

return 0

