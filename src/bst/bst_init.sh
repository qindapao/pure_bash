. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_init]++)) && return 0


# 初始化一颗二叉树
bst_init () 
{ 
    local -n _bst_init_tree_ref=$1
    local _bst_init_root_value=$2
    # 值为0表示下面没有挂任何东西
    _bst_init_tree_ref[root.left]=0
    _bst_init_tree_ref[root.right]=0
    _bst_init_tree_ref[root.value]=$_bst_init_root_value
    # 父节点的ID
    _bst_init_tree_ref[root.parent]=0
    # 左边left 右边right
    _bst_init_tree_ref[root.parent_side]=''
    # id计数,用于记录树节点ID,每增加一个就加1
    _bst_init_tree_ref[idcount]=1
    # 回收的ID列表,如果有节点被删除,那么它的ID被回收
    # 10 20 
    _bst_init_tree_ref[recycle_ids]='()'
}

return 0

