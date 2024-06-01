. ./meta/meta.sh
((DEFENSE_VARIABLES[array_filter]++)) && return 0


# 过滤掉某些数组中满足条件的元素，并且更新原数组(原数组处理后不是稀疏数组)
# 只考虑数组的情况(不考虑关联数组,关联数组用单独的函数处理)
# :TODO: index还有没有意义?这里数组的index可能已经改变
array_filter ()
{
    local -n _array_filter_ref_arr="${1}"
    local _array_filter_copy_arr=("${_array_filter_ref_arr[@]}")
    _array_filter_ref_arr=()
    local _array_filter_function="${2}"
    shift 2

    local _array_filter_i

    for _array_filter_i in "${!_array_filter_copy_arr[@]}" ; do
        if ! "$_array_filter_function" "${_array_filter_copy_arr["$_array_filter_i"]}" "$_array_filter_i" "${@}" ; then
            _array_filter_ref_arr+=("${_array_filter_copy_arr["$_array_filter_i"]}")
        fi
    done
}

return 0

