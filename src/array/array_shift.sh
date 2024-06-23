. ./meta/meta.sh
((DEFENSE_VARIABLES[array_shift]++)) && return 0


# 删除数组的第一个元素并且返回,支持稀疏数组与非稀疏
# 使用方法 element=$(array_shift "arr_name")
# :TODO: 目前有一个问题,$(function xx yy)这种调用方式是在子shell中执行的,因此
#        无法更改父shell环境中的数组,所以原始的数组无法被更新,需要调用两次函数解决
#        first_element=$(array_shift my_arr)
#        array_shift
#        但是这样感觉很冗余了
#        如果通过引用变量传递需要获取的元素又无法在命令替换的$()中使用,用起来不方便
#        鱼和熊掌不可兼得!
array_shift ()
{
    local -n _array_shift_ref_arr="${1}"
    local array_shift_shift_element=
    local _array_shift_indexs=("${!_array_shift_ref_arr[@]}")
    ((${#_array_shift_indexs[@]})) || return
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
    printf "%s" "$array_shift_shift_element"
}

return 0

