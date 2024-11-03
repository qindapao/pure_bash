. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_it]++)) && return 0


# Inorder Traversal
# 其实这里用的还是反向中序遍历(右-root-左)或者中序遍历
# 1: 二叉树数据结构引用
# 2: 需要打印的根节点
# 3: 打印格式(默认为0 ascii) 1 表示unicode格式
# 4: 打印的方向(默认为0 正向打印) 1 表示反向打印
#   0: 反向中序遍历
#   1: 正向中序遍历
bst_it () 
{
    local -n _bst_it_tree_ref=$1
    local -a _bst_it_stack=("$2" # 根节点
                              0    # 缩进值
                              -1   # 是父节点的左/右节点吗?(如果是反向打印这里的含义是左)
                              ''   # 打印前缀
                              1    # 有右子节点
                              1    # 有左子节点
                              0)   # 节点访问状态 0: 第一次访问 1: 右子树访问完成 2: 节点完全遍历,出栈
    local _bst_it_print_style=${3:-0}
    local _bst_it_print_direc=${4:-0}
    local _bst_it_print_opo_direc=

    case "$_bst_it_print_style" in
    0) # ascii 格式
        local _bst_it_vert='|'
        local _bst_it_u_r_arraw='.-->'
        local _bst_it_d_r_arraw="'-->"
        local _bst_it_r_sign='|-- '
        ;;
    1) # unicode 格式
        local _bst_it_vert='│'
        local _bst_it_u_r_arraw='┌──>'
        local _bst_it_d_r_arraw='└──>'
        local _bst_it_r_sign='│── '
        ;;
    esac

    case "$_bst_it_print_direc" in
    0)
    _bst_it_print_direc='right'
    _bst_it_print_opo_direc='left'
    ;;
    1)
    _bst_it_print_direc='left'
    _bst_it_print_opo_direc='right'
    ;;
    esac

    local _bst_it_{node=,indent=,is_left=,pre=,has_r_child=,has_l_child=,node_sts=}
    local _bst_it_pre_new=
    local _bst_it_indent_next=

    while((${#_bst_it_stack[@]})) ; do
        _bst_it_node_sts=${_bst_it_stack[-1]}
        _bst_it_has_l_child=${_bst_it_stack[-2]}
        _bst_it_has_r_child=${_bst_it_stack[-3]}
        _bst_it_pre=${_bst_it_stack[-4]}
        _bst_it_is_left=${_bst_it_stack[-5]}
        _bst_it_indent=${_bst_it_stack[-6]}
        _bst_it_node=${_bst_it_stack[-7]}

        case "$_bst_it_node_sts" in
        0)
        # 状态切换
        let '_bst_it_stack[-1]++'
        # 右子树入栈
        ((_bst_it_tree_ref[${_bst_it_node}.${_bst_it_print_direc}])) && {
            ((_bst_it_has_r_child)) && _bst_it_pre+='    ' || _bst_it_pre+="${_bst_it_vert}   "
            _bst_it_stack+=("${_bst_it_tree_ref[${_bst_it_node}.${_bst_it_print_direc}]}"
                "$((_bst_it_indent+1))" 1 "$_bst_it_pre" 1 0 0) ; }
        ;;
        1)
        # 状态切换
        let '_bst_it_stack[-1]++'
        if ((_bst_it_is_left==1)) ; then
            printf "%s%s%q(%s)\n" "$_bst_it_pre" "$_bst_it_u_r_arraw" "${_bst_it_tree_ref[${_bst_it_node}.value]}" "$_bst_it_node"
        elif ((_bst_it_is_left==0)) ; then
            printf "%s%s%q(%s)\n" "$_bst_it_pre" "$_bst_it_d_r_arraw" "${_bst_it_tree_ref[${_bst_it_node}.value]}" "$_bst_it_node"
        else
            printf "%s%q(%s)\n" "$_bst_it_r_sign" "${_bst_it_tree_ref[${_bst_it_node}.value]}" "$_bst_it_node"
        fi
        ;;
        2)
        # 出栈
        eval -- unset -v '_bst_it_stack[{-7..-1}]'
        # 左子树入栈
        ((_bst_it_tree_ref[${_bst_it_node}.${_bst_it_print_opo_direc}])) && {
            ((_bst_it_has_l_child)) && _bst_it_pre+='    ' || _bst_it_pre+="${_bst_it_vert}   "
            _bst_it_stack+=(
                "${_bst_it_tree_ref[${_bst_it_node}.${_bst_it_print_opo_direc}]}"
                "$((_bst_it_indent+1))" 0 "$_bst_it_pre" 0 1 0) ; }
        ;;
        esac
    done

    printf "idcount=%s\n" "${_bst_it_tree_ref[idcount]}"
    printf "recycle_ids=%s\n" "${_bst_it_tree_ref[recycle_ids]}"
}

return 0

