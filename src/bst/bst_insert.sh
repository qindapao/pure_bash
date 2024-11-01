. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_insert]++)) && return 0


# 二叉树插入一个节点
bst_insert () 
{ 
    local -n _bst_insert_tree_ref=$1
    local -n _bst_insert_tree_id_ref=$2
    local _bst_insert_parent=$3
    local _bst_insert_direction=$4
    local _bst_insert_value=$5
    local _bst_insert_node_id=
    local -a _bst_insert_recycle_ids=()
    
    # 插入一个新节点
    if [[ "${_bst_insert_tree_ref[recycle_ids]}" != '()' ]] ; then
        eval _bst_insert_recycle_ids=${_bst_insert_tree_ref[recycle_ids]}
        _bst_insert_node_id=${_bst_insert_recycle_ids[-1]}
        unset -v _bst_insert_recycle_ids[-1]
        # 这是更防呆的写法,不过当前场景简单处理即可(当前场景下都是数字值)
        # printf -v m "(%s)" "${a[*]@Q}"
        _bst_insert_tree_ref[recycle_ids]="(${_bst_insert_recycle_ids[*]})"
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

