. ./meta/meta.sh
((DEFENSE_VARIABLES[array_pop]++)) && return 0

# 这个函数也无用,直接操作更简单
# 删除数组的最后一个元素并且返回
# 使用方法 array_pop "arr_name" 'ret'
# 0: 数组不为空，并返回元素
# 1: 数组为空
array_pop ()
{
    local -n _array_pop_ref_{arr="$1",ret="$2"}
    local _array_pop_ref_pop_element=
    ((${#_array_pop_ref_arr[@]})) || return 1
    
    _array_pop_ref_pop_element="${_array_pop_ref_arr[-1]}"
    # 这个语法bash4.3才支持,数据的负向索引是从4.3才开始引入的
    unset -v '_array_pop_ref_arr[-1]'
    _array_pop_ref_ret="$_array_pop_ref_pop_element"
    return 0
}

return 0

