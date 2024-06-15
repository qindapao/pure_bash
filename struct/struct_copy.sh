. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_copy]++)) && return 0

# 树状打印一个结构体变量
# 第一级要么是一个数组要么是一个关联数组
# 依次遍历,使用栈的思想
struct_copy ()
{
    local -n _struct_copy_old="${1}" _struct_copy_new="${2}"
    local _struct_copy_index

    _struct_copy_new=()

    for _struct_copy_index in "${!_struct_copy_old[@]}" ; do
        _struct_copy_new["${_struct_copy_index}"]="${_struct_copy_old["$_struct_copy_index"]}"
    done
}

return 0

