. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_del]++)) && return 0


_bst_del_node ()
{
    local -n __bst_del_node_ref="$1"
    local __bst_del_node_id="$2"
    unset -v '__bst_del_node_ref[${__bst_del_node_id}]' \
        '__bst_del_node_ref[${__bst_del_node_id}.left]' \
        '__bst_del_node_ref[${__bst_del_node_id}.right]' \
        '__bst_del_node_ref[${__bst_del_node_id}.value]' \
        '__bst_del_node_ref[${__bst_del_node_id}.parent]' \
        '__bst_del_node_ref[${__bst_del_node_id}.parent_side]'
    __bst_del_node_ref[recycle_ids]+=" ${__bst_del_node_id}"
}

# 二叉树删除一个节点
bst_del () 
{
    local -n _bst_del_ref=$1
    local _bst_del_root_id=$2
    local _bst_del_out_id=$3
    local _bst_del_value=$4
    local _bst_del_current=$_bst_del_root_id
    local _bst_del_parent=0
    local _bst_del_is_l_child=1
    local _bst_del_sa=${_bst_del_ref[sa]}
    local _bst_del_sa_ret=0
    local _bst_del_tmp_id=

    if ((_bst_del_current)) ; then
        "$_bst_del_sa" "${_bst_del_ref[${_bst_del_current}.value]}" "$_bst_del_value"
        _bst_del_sa_ret=$?
    fi

    while ((_bst_del_current)) && ((_bst_del_sa_ret!=2)) ; do
        _bst_del_parent=$_bst_del_current
        "$_bst_del_sa" "${_bst_del_ref[${_bst_del_current}.value]}" "$_bst_del_value"
        case "$?" in
        0)  _bst_del_current=${_bst_del_ref[${_bst_del_current}.left]}
            _bst_del_is_l_child=1 ;;
        1)  _bst_del_current=${_bst_del_ref[${_bst_del_current}.right]}
            _bst_del_is_l_child=0 ;;
        esac
    done

    ((_bst_del_current)) || {
        _bst_del_out_id=$_bst_del_root_id
        return ${BST_COMMON_ERR_DEFINE[del_not_found]}
    }

    # 叶子节点
    if ! ((_bst_del_ref[${_bst_del_current}.left])) &&
        ! ((_bst_del_ref[${_bst_del_current}.right])) ; then
        # 如果删除的是根节点并且没有子节点,树为空
        if ((_bst_del_current==_bst_del_root_id)) ; then
            _bst_del_node "$1" "$_bst_del_root_id"
            _bst_del_out_id=0
            return ${BST_COMMON_ERR_DEFINE[del_root_node]}
        fi
    elif ! ((_bst_del_ref[${_bst_del_current}.left])) &&                                                             
        # 只有一个右子节点                                               #   (parrent)30            (parrent)30      
        _bst_del_tmp_id=${_bst_del_ref[${_bst_del_current}.right]}       #            |                      | 
        if ((_bst_del_current==_bst_del_root_id)) ; then                 #    .-------'----.         .-------'----.  
            # 释放根节点                                                 #    |       .    |         |       .    |  
            _bst_del_out_id=${_bst_del_tmp_id}                           #    |       .              |       .    |  
            _bst_del_node "$1" "$_bst_del_root_id"                       #cur 20(X)   .   50         20      .   50(X) current
            return ${BST_COMMON_ERR_DEFINE[ok]}                          #    '---.   .          .---'---.   .    '-----.
        fi                                                               #        |   .          |       |   .          |
                                                                         #        25 <'         15       25  '.........>70
        if ((_bst_del_is_l_child)) ; then
            _bst_del_ref[${_bst_del_parent}.left]=${_bst_del_tmp_id}
            _bst_del_ref[${_bst_del_tmp_id}.parent_side]='left'
        else
            _bst_del_ref[${_bst_del_parent}.right]=${_bst_del_tmp_id}
            _bst_del_ref[${_bst_del_tmp_id}.parent_side]='right'
        fi
        _bst_del_ref[${_bst_del_tmp_id}.parent]=$_bst_del_parent

        # 释放当前节点内存
        _bst_del_node "$1" "$_bst_del_current"
    elif ! ((_bst_del_ref[${_bst_del_current}.right])) &&                                                             
        # 只有一个左子节点                                               #       (parrent)30            (parrent)30      
        _bst_del_tmp_id=${_bst_del_ref[${_bst_del_current}.left]}        #                |                      | 
        if ((_bst_del_current==_bst_del_root_id)) ; then                 #        .-------'----.         .-------'----------.
            # 释放根节点                                                 #        |       .    |         |       .          |
            _bst_del_out_id=${_bst_del_tmp_id}                           #        |       .              |       .          |
            _bst_del_node "$1" "$_bst_del_root_id"                       #    cur 20(X)   .   50         20      .          50(X) current
            return ${BST_COMMON_ERR_DEFINE[ok]}                          #    .---'       .          .---'---.   .          |
        fi                                                               #    |           .          |       |   .       .--'    
                                                                         #   15<..........'         15       25  .       |       
        if ((_bst_del_is_l_child)) ; then                                #                                       '.....>40       
            _bst_del_ref[${_bst_del_parent}.left]=${_bst_del_tmp_id}
            _bst_del_ref[${_bst_del_tmp_id}.parent_side]='left'
        else                                                             #
            _bst_del_ref[${_bst_del_parent}.right]=${_bst_del_tmp_id}    #              30(->35)current    delete node 30
            _bst_del_ref[${_bst_del_tmp_id}.parent_side]='right'         #              |
        fi                                                               #       .------'------.
        _bst_del_ref[${_bst_del_tmp_id}.parent]=$_bst_del_parent         #       |      ^      |
                                                                         #      20      .      50
        # 释放当前节点内存                                               #       |      .      |
        _bst_del_node "$1" "$_bst_del_current"                           #       '---.  .  .---'---.
    fi                                                                   #           |  .  |       |
                                                                         #           25 '.>35(X)   60
}                                                                        #           |    (->30)   |
                                                                         #       .---'             '--.
return 0                                                                 #       |                    |
                                                                         #       24                   70
                                                                         #




# 参考代码
class TreeNode:
    def __init__(self, key):
        self.left = None
        self.right = None
        self.val = key

def minValueNode(node):
    current = node
    while current.left is not None:
        current = current.left
    return current

def deleteNode(root, key):
    current = root
    parent = None
    is_left_child = True

    while current and current.val != key:
        parent = current
        if key < current.val:
            current = current.left
            is_left_child = True
        else:
            current = current.right
            is_left_child = False

    if current is None:  # 未找到节点
        return root

    if current.left is None and current.right is None:  # 叶子节点
        if current == root:
            return None
        if is_left_child:
            parent.left = None
        else:
            parent.right = None
    elif current.left is None:  # 只有一个右子节点
        if current == root:
            return current.right
        if is_left_child:
            parent.left = current.right
        else:
            parent.right = current.right
    elif current.right is None:  # 只有一个左子节点
        if current == root:
            return current.left
        if is_left_child:
            parent.left = current.left
        else:
            parent.right = current.left
    else:  # 有两个子节点
        # 找到右子树中最小的节点
        successor = minValueNode(current.right)
        successor_val = successor.val

        # 用后继节点值替换当前节点值
        current.val = successor_val
        
        # 删除后继节点
        parent_of_successor = current
        child = current.right
        while child.left is not None:
            parent_of_successor = child
            child = child.left

        # 修正后继节点位置
        if parent_of_successor != current:
            parent_of_successor.left = child.right
        else:
            current.right = child.right

    return root

# 示例用法
root = TreeNode(50)
root = insert(root, 30)
root = insert(root, 20)
root = insert(root, 40)
root = insert(root, 70)
root = insert(root, 60)
root = insert(root, 80)

root = deleteNode(root, 20)  # 删除叶子节点
root = deleteNode(root, 30)  # 删除只有一个子节点的节点
root = deleteNode(root, 50)  # 删除有两个子节点的节点








