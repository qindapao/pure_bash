. ./meta/meta.sh
((DEFENSE_VARIABLES[array_map]++)) && return 0


# 数组的map函数，对数组中的每个元素执行特定的函数
# 1: 需要操作的数组的名字
# 2: 函数名(提供一个操作函数,这个函数依次作用于每个数组元素并改变它)
#           
# @: 其它参数为这个函数需要的参数(函数的第一个参数默认为当前数组元素)
#       每次执行后的结果作为下次的输入
#       提供的函数范例(当前是不带参数的,还可以带参数)
#       str_basename ()
#       {
#           local in_str="$1"
#           out_str=${in_str##*/}
#           out_str=${out_str%%.*}
#           printf "%s" "$out_str"
#       }
# 最后一个参数可选: 当前迭代数组索引

array_map ()
{
    local -n _array_map_ref_arr="${1}"
    local _array_map_function="${2}"
    shift 2
    local _array_map_function_params=("${@}")
    local _array_map_index
    for _array_map_index in "${!_array_map_ref_arr[@]}" ; do
        _array_map_ref_arr[$_array_map_index]=$("$_array_map_function" "${_array_map_ref_arr["$_array_map_index"]}" "$_array_map_index" "${_array_map_function_params[@]}")
    done
}

return 0

