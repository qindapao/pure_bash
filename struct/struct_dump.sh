. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_dump]++)) && return 0

. ./array/array_sort.sh || return 1

# 树状打印一个结构体变量
# 第一级要么是一个数组要么是一个关联数组
# 依次遍历,使用栈的思想

# 使用迭代栈来实现
_struct_dump ()
{
    # 1: 节点层级 2: 节点键名 3: 节点值 4: 节点符号(数组或者关联数组)
    local -a __struct_dump_tree_nodes=("${@}")

    local -i __struct_dump_tree_node_lev=0
    local __struct_dump_tree_node_key=""
    local __struct_dump_tree_node_value=""
    local __struct_dump_printf_mark=""

    local __struct_dump_index=''
    # 如果是用递归函数,那么用-gt >
    local __struct_dump_var sort_method='-lt'
    local -a __struct_dump_var_indexs=()

    while((${#__struct_dump_tree_nodes[@]})) ; do
        __struct_dump_printf_mark="${__struct_dump_tree_nodes[-1]}"
        __struct_dump_tree_node_value="${__struct_dump_tree_nodes[-2]}"
        __struct_dump_tree_node_key="${__struct_dump_tree_nodes[-3]}"
        __struct_dump_tree_node_lev="${__struct_dump_tree_nodes[-4]}"
        eval unset __struct_dump_tree_nodes[{-4..-1}]

        if [[ "$__struct_dump_tree_node_value" =~ ^(declare)\ ([^\ ]+)\ _struct_set_field_data_lev[0-9]+=(.*) ]] ; then
            # 不是叶子节点,先打印当前数据结构的键,然后把当前键值对压入栈中
            printf "%*s%q%s\n" "$((4*(__struct_dump_tree_node_lev)))" ' ' "$__struct_dump_tree_node_key" " ${__struct_dump_printf_mark} "
            # 变量类型可能改变,这里必须unset,这里和递归不同,递归只用一次
            unset __struct_dump_var
            declare ${BASH_REMATCH[2]} __struct_dump_var
            eval __struct_dump_var="${BASH_REMATCH[3]}"
            __struct_dump_var_indexs=("${!__struct_dump_var[@]}")
            
            if [[ "${__struct_dump_var@a}" == *A* ]] ; then
                # 如果是用递归函数,那么用-gt <
                sort_method='<'
                __struct_dump_printf_mark='=>'
            else
                __struct_dump_printf_mark='='
            fi
            array_sort __struct_dump_var_indexs "$sort_method"

            # 压栈
            for __struct_dump_index in "${__struct_dump_var_indexs[@]}" ; do
                __struct_dump_tree_nodes+=("$((__struct_dump_tree_node_lev+1))" "$__struct_dump_index" "${__struct_dump_var["$__struct_dump_index"]}" "$__struct_dump_printf_mark")
            done
        else
            # 叶子节点,直接打印就好
            printf "%*s%q%s%q\n" "$((4*(__struct_dump_tree_node_lev)))" ' ' "$__struct_dump_tree_node_key"  " ${__struct_dump_printf_mark} " "$__struct_dump_tree_node_value"
        fi
    done
}

# # 递归实现struct_dump 深度优先遍历DFS(多叉树)
# _struct_dump ()
# {
#     local -i __struct_dump_tree_node_lev="${1}"
#     local __struct_dump_tree_node_key="${2}"
#     local __struct_dump_tree_node_value="${3}"
#     local __struct_dump_printf_mark="${4}"

#     local __struct_dump_index=''
#     local __struct_dump_var sort_method='-gt'
#     local -a __struct_dump_var_indexs=()

#     if [[ "$__struct_dump_tree_node_value" =~ ^(declare)\ ([^\ ]+)\ _struct_set_field_data_lev[0-9]+=(.*) ]] ; then
#         # 不是叶子节点,先打印当前数据结构的键,然后迭代当前数据结构递归调用_struct_dump
#         printf "%*s%q%s\n" "$((4*(__struct_dump_tree_node_lev)))" ' ' "$__struct_dump_tree_node_key" " ${__struct_dump_printf_mark} "
#         declare ${BASH_REMATCH[2]} __struct_dump_var
#         eval __struct_dump_var="${BASH_REMATCH[3]}"
#         __struct_dump_var_indexs=("${!__struct_dump_var[@]}")
        
#         if [[ "${__struct_dump_var@a}" == *A* ]] ; then
#             sort_method='>'
#             __struct_dump_printf_mark='=>'
#         else
#             __struct_dump_printf_mark='='
#         fi
#         array_sort __struct_dump_var_indexs "$sort_method"

#         for __struct_dump_index in "${__struct_dump_var_indexs[@]}" ; do
#             # 递归调用
#             _struct_dump "$((__struct_dump_tree_node_lev+1))" "$__struct_dump_index" "${__struct_dump_var["$__struct_dump_index"]}" "$__struct_dump_printf_mark"
#         done
#     else
#         # 是叶子节点需要退出了
#         printf "%*s%q%s%q\n" "$((4*(__struct_dump_tree_node_lev)))" ' ' "$__struct_dump_tree_node_key"  " ${__struct_dump_printf_mark} " "$__struct_dump_tree_node_value"
#         return
#     fi
# }

struct_dump ()
{
    # 首先把最外层的数据引用传进来
    local -n _struct_dump_struct_ref="${1}"
    local _struct_dump_index='' _struct_dump_printf_mark='=' _struct_dump_sort_method='-gt'
    [[ "${_struct_dump_struct_ref@a}" == *A* ]] && {
        _struct_dump_sort_method='>' ;  _struct_dump_printf_mark='=>'
    }
    printf "%s %s\n" "${1}" "$_struct_dump_printf_mark"
    local _struct_dump_indexs=("${!_struct_dump_struct_ref[@]}")
    # 如果是关联数组按照字典排序,否则按照数字排序(默认按照数字排序)
    array_sort _struct_dump_indexs "$_struct_dump_sort_method"

    for _struct_dump_index in "${_struct_dump_indexs[@]}" ; do
        _struct_dump '1' "$_struct_dump_index" "${_struct_dump_struct_ref["$_struct_dump_index"]}" "$_struct_dump_printf_mark"
    done
}

return 0

