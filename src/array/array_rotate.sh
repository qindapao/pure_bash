. ./meta/meta.sh
((DEFENSE_VARIABLES[array_rotate]++)) && return 0


# 数组的轮转(不改变索引)
# 1: 需要操作的数组引用
# 2: 旋转步长
#       正数: 向左旋转一个给定步长
#       负数: 向右旋转一个给定步长(顺时针,最后元素变成最前元素)
array_rotate ()
{
    local -n _array_rotate_ref_arr="${1}"
    local -i _array_rotate_step="${2}"
    local -i _array_rotate_arr_size=${#_array_rotate_ref_arr[@]}
    
    ((_array_rotate_arr_size)) || return
    local -a _array_rotate_arr_indexs=("${!_array_rotate_ref_arr[@]}")
    local -a _array_rotate_arr_tmp_arr=("${_array_rotate_ref_arr[@]}")
    
    local _array_rotate_index
    for((_array_rotate_index=0;_array_rotate_index<_array_rotate_arr_size;_array_rotate_index++)) ; do
        _array_rotate_ref_arr[${_array_rotate_arr_indexs[_array_rotate_index]}]=${_array_rotate_arr_tmp_arr[(_array_rotate_index+_array_rotate_step)%_array_rotate_arr_size]}
    done
}

return 0

