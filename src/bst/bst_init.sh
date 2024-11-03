. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_init]++)) && return 0

# 0: a > b
# 1: a < b
# 2: a = b
_bst_default_sa ()
{
    local a=$1 b=$2
    ((a>b)) && return 0
    ((a<b)) && return 1
    ((a==b)) && return 2
}

# 初始化一颗二叉树.并且返回根节点的ID
bst_init () 
{ 
    local -n _bst_init_tree_ref=$1
    local -n _bst_init_out_root_ref=$2
    local _bst_init_root_value=$3
    # 注册排序算法函数,默认数字排序
    local _bst_init_sort_algorithms=${4:-_bst_default_sa}
    # 主键只是用于表示节点存在
    _bst_init_tree_ref[1]=1
    # 值为0表示下面没有挂任何东西
    _bst_init_tree_ref[1.left]=0
    _bst_init_tree_ref[1.right]=0
    _bst_init_tree_ref[1.value]=$_bst_init_root_value
    # 父节点的ID
    _bst_init_tree_ref[1.parent]=0
    # 左边left 右边right
    _bst_init_tree_ref[1.parent_side]=''
    # id计数,用于记录树节点ID,每增加一个就加1
    _bst_init_tree_ref[idcount]=2
    # 回收的ID列表,如果有节点被删除,那么它的ID被回收
    #  10 20 
    _bst_init_tree_ref[recycle_ids]=''
    # 挂接排序算法
    _bst_init_tree_ref[sa]="$_bst_init_sort_algorithms"
    _bst_init_out_root_ref=1
}

return 0

