. ./meta/meta.sh
((DEFENSE_VARIABLES[array_tail]++)) && return 0

# 取数组的最后一个元素，但是不删除它(对应 pop)
# 这个函数意义不大,直接用${arr[-1]}更好
# :TODO: 使用$()方式取值会丢失末尾换行符
array_tail ()
{
    local -n _array_tail_ref_arr=$1
    ((${#_array_tail_ref_arr[@]})) || return

    printf "%s" "${_array_tail_ref_arr[-1]}"
}

return 0

