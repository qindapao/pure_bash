. ./meta/meta.sh
((DEFENSE_VARIABLES[array_first_value]++)) && return 0

# 返回数组中满足一系列条件(可能不只一个)的第一个值
# 1: 数组引用
# 2: 条件函数
# @: 条件函数带的参数
array_first_value ()
{
    local -n _array_first_value_ref_arr="${1}"
    local _array_first_value_function="${2}"
    shift 2

    local _array_first_value_i

    for _array_first_value_i in "${!_array_first_value_ref_arr[@]}" ; do
        if "$_array_first_value_function" "${_array_first_value_ref_arr["$_array_first_value_i"]}" "$_array_first_value_i" "${@}" ; then
            printf "%s" "${_array_first_value_ref_arr["$_array_first_value_i"]}"
            break
        fi
    done
}

return 0

