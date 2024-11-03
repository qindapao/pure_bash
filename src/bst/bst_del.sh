. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_del]++)) && return 0


# 二叉树插入一个节点
bst_del () 
{ 
    local -n _bst_del_tree_ref=$1
    local _bst_del_node=$2

    if [[ -z "${_bst_del_tree_ref[$]}" ]]
    

    local -n _bst_insert_tree_ref=$1
    local -n _bst_insert_tree_id_ref=$2
    local _bst_insert_parent=$3
    local _bst_insert_direction=$4
    local _bst_insert_value=$5
    local _bst_insert_node_id=
    local _bst_insert_recycle_ids
    
    # 插入一个新节点
    if [[ -n "${_bst_insert_tree_ref[recycle_ids]}" ]] ; then
        _bst_insert_node_id=${_bst_insert_recycle_ids##* }
        _bst_insert_recycle_ids=${_bst_insert_recycle_ids% *}
        # 重新生成数组的方法
        # printf -v m "(%s)" "${a[*]@Q}"
    else
        _bst_insert_node_id=$((_bst_insert_tree_ref[idcount]++))
    fi

    _bst_insert_tree_ref[${_bst_insert_node_id}.left]=0
    _bst_insert_tree_ref[${_bst_insert_node_id}.right]=0
    _bst_insert_tree_ref[${_bst_insert_node_id}.value]=$_bst_insert_value
    # 挂接父节点
    _bst_insert_tree_ref[${_bst_insert_parent}.${_bst_insert_direction}]=$_bst_insert_node_id
    # 保存父节点的引用和方向
    _bst_insert_tree_ref[${_bst_insert_node_id}.parent]=$_bst_insert_parent
    _bst_insert_tree_ref[${_bst_insert_node_id}.parent_side]=$_bst_insert_direction
    # 返回节点ID
    _bst_insert_tree_id_ref=$_bst_insert_node_id
}

return 0

