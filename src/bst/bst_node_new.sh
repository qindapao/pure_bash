. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_node_new]++)) && return 0


# 二叉树是中增加一个节点
bst_node_new () 
{ 
    local -n _bst_node_new_root_ref=$1
    local -n _bst_node_new_out_id=$2
    local _bst_node_new_value=$3

    # 插入一个新节点
    if [[ -n "${_bst_node_new_root_ref[recycle_ids]}" ]] ; then
        _bst_node_new_out_id=${_bst_node_new_root_ref[recycle_ids]##* }
        _bst_node_new_root_ref[recycle_ids]=${_bst_node_new_root_ref[recycle_ids]% *}
        # 重新生成数组的方法
        # printf -v m "(%s)" "${a[*]@Q}"
    else
        _bst_node_new_out_id=$((_bst_node_new_root_ref[idcount]++))
    fi

    _bst_node_new_root_ref[${_bst_node_new_out_id}]=1
    _bst_node_new_root_ref[${_bst_node_new_out_id}.left]=0
    _bst_node_new_root_ref[${_bst_node_new_out_id}.right]=0
    _bst_node_new_root_ref[${_bst_node_new_out_id}.value]=$_bst_node_new_value
    # 保存父节点的引用和方向
    _bst_node_new_root_ref[${_bst_node_new_out_id}.parent]=0
    _bst_node_new_root_ref[${_bst_node_new_out_id}.parent_side]=''
    # 返回节点ID
}

return 0

