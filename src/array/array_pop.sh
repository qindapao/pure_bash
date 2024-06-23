. ./meta/meta.sh
((DEFENSE_VARIABLES[array_pop]++)) && return 0

# 这个函数也无用,直接操作更简单
# 删除数组的最后一个元素并且返回
# 使用方法 element=$(array_pop "arr_name")
array_pop ()
{
    local -n _array_pop_ref_arr="${1}"
    local _array_pop_ref_pop_element=
    ((${#_array_pop_ref_arr[@]})) || return 
    
    _array_pop_ref_pop_element="${_array_pop_ref_arr[-1]}"
    # 这个语法bash4.3才支持,数据的负向索引是从4.3才开始引入的
    unset '_array_pop_ref_arr[-1]'
    printf "%s" "$_array_pop_ref_pop_element"
}

return 0

