. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_dump]++)) && return 0

. ./array/array_sort.sh || return 1

# 树状打印一个结构体变量
# 第一级要么是一个数组要么是一个关联数组
# 依次遍历,使用栈的思想
# :TODO: 是否需要提高性能?如果打印到变量中,printf -v 即可
# :TODO: 在传入1参数的情况下是否跨行打印原始字符串的值%s ? 忽略缩进，并且打印可能会显得很混乱，暂时不实现

# 使用迭代栈来实现
#   函数传参说明
#   1: 打印的格式(是一个bitmap)
#       这个bitmap的定义如下:
#           bit0: 
#               0: 打印q字符串(默认值)
#               1: 打印原始字符串
#           bit1:
#               0: 横向打印(默认值)
#               1: 纵向打印
#       00: 横向的Q字符串(默认值)
#       01: 横向原始字符串
#       10: 纵向Q字符串(用于可重新加载的配置文件[struct_load])
#       11: 纵向原始字符串
#   @: 元组,每组4个数组
#       1: 节点层级
#       2: 节点键名
#       3: 节点值
#       4: 节点符号  
_struct_dump ()
{
    local __struct_dump_print_type_bit_map=$1
    shift
    # 1: 节点层级 2: 节点键名 3: 节点值 4: 节点符号(数组或者关联数组)
    local -a __struct_dump_tree_nodes=("${@}")

    local -i __struct_dump_tree_node_lev=0
    local __struct_dump_tree_node_key="" __struct_dump_tree_node_key_padding=""
    local __struct_dump_tree_node_value_padding=""
    local __struct_dump_tree_node_value=""
    local __struct_dump_printf_mark=""

    local __struct_dump_index=''
    # 如果是用递归函数,那么用-gt >
    local __struct_dump_var __struct_dump_sort_method='-lt'
    local -a __struct_dump_var_indexs=()

    while((${#__struct_dump_tree_nodes[@]})) ; do
        __struct_dump_printf_mark="${__struct_dump_tree_nodes[-1]}"
        __struct_dump_tree_node_value="${__struct_dump_tree_nodes[-2]}"
        __struct_dump_tree_node_key="${__struct_dump_tree_nodes[-3]}"
        __struct_dump_tree_node_lev="${__struct_dump_tree_nodes[-4]}"
        eval unset __struct_dump_tree_nodes[{-4..-1}]

        # 如果嵌套层数过深,这里会非常耗时,当字符数量达到千万级,这里需要4秒
        if [[ "$__struct_dump_tree_node_value" =~ ^(declare)\ ([^\ ]+)\ _struct_set_field_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev[0-9]+=(.*) ]] ; then
            # 不是叶子节点,先打印当前数据结构的键,然后把当前键值对压入栈中
            case "$__struct_dump_print_type_bit_map" in
            1|3)  
                printf -v __struct_dump_tree_node_key_padding "%-$((4*__struct_dump_tree_node_lev))s" ' '
                __struct_dump_tree_node_key_padding=${__struct_dump_tree_node_key//$'\n'/$'\n'$__struct_dump_tree_node_key_padding}
                
                printf "%*s%s%s\n" "$((4*__struct_dump_tree_node_lev))" ' ' "$__struct_dump_tree_node_key_padding" " ${__struct_dump_printf_mark}" 
                ;;
            0|2)
                printf "%*s%q%s\n" "$((4*__struct_dump_tree_node_lev))" ' ' "$__struct_dump_tree_node_key" " ${__struct_dump_printf_mark}" ;;
            esac

            # 变量类型可能改变,这里必须unset,这里和递归不同,递归只用一次
            unset __struct_dump_var
            declare ${BASH_REMATCH[2]} __struct_dump_var
            eval __struct_dump_var="${BASH_REMATCH[3]}"
            __struct_dump_var_indexs=("${!__struct_dump_var[@]}")
            
            if [[ "${__struct_dump_var@a}" == *A* ]] ; then
                # 如果是用递归函数,那么用-gt <
                __struct_dump_sort_method='<'
                __struct_dump_printf_mark='⇒'
            else
                __struct_dump_printf_mark='⩦'
            fi
            array_sort __struct_dump_var_indexs "$__struct_dump_sort_method"

            # 压栈
            for __struct_dump_index in "${__struct_dump_var_indexs[@]}" ; do
                __struct_dump_tree_nodes+=("$((__struct_dump_tree_node_lev+1))" "$__struct_dump_index" "${__struct_dump_var["$__struct_dump_index"]}" "$__struct_dump_printf_mark")
            done
        else
            case "$__struct_dump_print_type_bit_map" in
            1|3)
                printf -v __struct_dump_tree_node_key_padding "%-$((4*__struct_dump_tree_node_lev))s" ' '
                __struct_dump_tree_node_key_padding=${__struct_dump_tree_node_key//$'\n'/$'\n'$__struct_dump_tree_node_key_padding}

                printf -v __struct_dump_tree_node_value_padding "%-$((4*(__struct_dump_tree_node_lev+1)))s" ' '
                __struct_dump_tree_node_value_padding=${__struct_dump_tree_node_value//$'\n'/$'\n'$__struct_dump_tree_node_value_padding}
                ;;&
            0)  printf "%*s%q%s%q\n" "$((4*__struct_dump_tree_node_lev))" ' ' "$__struct_dump_tree_node_key"  " ${__struct_dump_printf_mark} " "$__struct_dump_tree_node_value" ;;
            1)  printf "%*s%s%s%s\n" "$((4*__struct_dump_tree_node_lev))" ' ' "$__struct_dump_tree_node_key_padding"  " ${__struct_dump_printf_mark} " "$__struct_dump_tree_node_value_padding" ;;
            2)
                printf "%*s%q%s\n" "$((4*__struct_dump_tree_node_lev))" ' ' "$__struct_dump_tree_node_key"  " ${__struct_dump_printf_mark} "
                printf "%*s%q\n" "$((4*__struct_dump_tree_node_lev))" ' ' "$__struct_dump_tree_node_value"
                ;;
            3)
                printf "%*s%s%s\n" "$((4*__struct_dump_tree_node_lev))" ' ' "$__struct_dump_tree_node_key_padding"  " ${__struct_dump_printf_mark} "
                printf "%*s%s\n" "$((4*__struct_dump_tree_node_lev))" ' ' "$__struct_dump_tree_node_value_padding"
                ;;
            esac
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

#     if [[ "$__struct_dump_tree_node_value" =~ ^(declare)\ ([^\ ]+)\ _struct_set_field_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev[0-9]+=(.*) ]] ; then
#         # 不是叶子节点,先打印当前数据结构的键,然后迭代当前数据结构递归调用_struct_dump
#         printf "%*s%q%s\n" "$((4*(__struct_dump_tree_node_lev)))" ' ' "$__struct_dump_tree_node_key" " ${__struct_dump_printf_mark}"
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

# 参数: 
#   1: 打印的格式(是一个bitmap)
#       这个bitmap的定义如下:
#           bit0: 
#               0: 打印q字符串(默认值)
#               1: 打印原始字符串
#           bit1:
#               0: 横向打印(默认值)
#               1: 纵向打印
#   2: 需要打印的结构体引用
struct_dump ()
{
    # 首先把最外层的数据引用传进来
    local _struct_dump_print_type_map="${1:-0}"
    local -n _struct_dump_struct_ref="${2}"
    
    # 如果不是数组原样打印
    # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# a=344xxx
    # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -n b=a
    # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# echo ${b@a}
    # 
    # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# a=(1 2 3 4)
    # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# echo ${b@a}
    # a
    # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -n c=b
    # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# echo ${c@a}
    # a
    # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p c
    # declare -n c="b"
    # 只有@a可以处理嵌套的应用传递,declare -p不行
    # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash#     
    if [[ "${_struct_dump_struct_ref@a}" != *[aA]* ]] ; then
        # 字符串打印
        printf "%s" "$_struct_dump_struct_ref"
        return
    fi

    # 不使用默认的等号和胖箭头是因为防止键和值都有这些字符
    local _struct_dump_index='' _struct_dump_printf_mark='⩦' _struct_dump_sort_method='-gt'
    [[ "${_struct_dump_struct_ref@a}" == *A* ]] && {
        _struct_dump_sort_method='>' ;  _struct_dump_printf_mark='⇒'
    }
    printf "%s %s\n" "${2}" "$_struct_dump_printf_mark"
    local _struct_dump_indexs=("${!_struct_dump_struct_ref[@]}")
    # 如果是关联数组按照字典排序,否则按照数字排序(默认按照数字排序)
    array_sort _struct_dump_indexs "$_struct_dump_sort_method"

    for _struct_dump_index in "${_struct_dump_indexs[@]}" ; do
        _struct_dump "$_struct_dump_print_type_map" '1' "$_struct_dump_index" "${_struct_dump_struct_ref["$_struct_dump_index"]}" "$_struct_dump_printf_mark"
    done
}

# 默认打印类型
alias struct_dump_hq='struct_dump 0'
alias struct_dump_ho='struct_dump 1'
alias struct_dump_vq='struct_dump 2'
alias struct_dump_vo='struct_dump 3'



return 0

