. ./meta/meta.sh
((DEFENSE_VARIABLES[array_shift_dense]++)) && return 0


# 数组按照稀疏数组处理,性能更高
array_shift_dense ()
{
    local -n _array_shift_dense_ref_{arr="$1",ret="$2"}
    ((${#_array_shift_dense_ref_arr[@]})) || return 1

    local _array_shift_dense_first_element="${_array_shift_dense_ref_arr[@]:0:1}"
    _array_shift_dense_ref_arr=("${_array_shift_dense_ref_arr[@]:1}")
    _array_shift_dense_ref_ret="$_array_shift_dense_first_element"
    return 0
}

return 0

