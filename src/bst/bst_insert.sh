. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_insert]++)) && return 0

. ./bst/bst_node_new.sh || return 1
. ./bst/bst_common.sh || return 1

# 二叉搜索树插入一个节点
bst_insert () 
{ 
    local -n _bst_insert_ref=$1
    local  _bst_insert_tree_in_id=$2
    local -n _bst_insert_tree_out_id=$3
    local _bst_insert_value=$4
    local _bst_insert_new_node_id=
    local _bst_insert_current="$_bst_insert_tree_in_id"
    local _bst_insert_sa="${_bst_insert_ref[sa]}"

    bst_node_new "$1" _bst_insert_new_node_id "$_bst_insert_value"

    if [[ -z "${_bst_insert_ref[$_bst_insert_tree_in_id]}" ]] ; then
        _bst_insert_tree_out_id="$_bst_insert_new_node_id"
        return ${BST_COMMON_ERR_DEFINE[insert_null_tree]}
    fi

    while true ; do
        "$_bst_insert_sa" "${_bst_insert_ref[${_bst_insert_current}.value]}" \
            "$_bst_insert_value"
        case "$?" in
        0)
        # 当前节点比要插入的值大,待插入的值放左叶子节点
        ((_bst_insert_ref[${_bst_insert_current}.left])) || {
            _bst_insert_ref[${_bst_insert_current}.left]=$_bst_insert_new_node_id
            _bst_insert_ref[${_bst_insert_new_node_id}.parent]=$_bst_insert_current
            _bst_insert_ref[${_bst_insert_new_node_id}.parent_side]='left'
            break
        }
        _bst_insert_current=${_bst_insert_ref[${_bst_insert_current}.left]}
        ;;
        1)
        # 当前节点比要插入的值小,待插入的值放右叶子节点
        ((_bst_insert_ref[${_bst_insert_current}.right])) || {
            _bst_insert_ref[${_bst_insert_current}.right]=$_bst_insert_new_node_id
            _bst_insert_ref[${_bst_insert_new_node_id}.parent]=$_bst_insert_current
            _bst_insert_ref[${_bst_insert_new_node_id}.parent_side]='right'
            break
        }
        _bst_insert_current=${_bst_insert_ref[${_bst_insert_current}.right]}
        ;;
        2)
        # 要i插入的节点值已经在树中不允许重复插入
        _bst_insert_tree_out_id=${_bst_insert_tree_in_id}
        return ${BST_COMMON_ERR_DEFINE[insert_same_e]}
        ;;
        esac
    done
    _bst_insert_tree_out_id=${_bst_insert_tree_in_id}
    return ${BST_COMMON_ERR_DEFINE[ok]}
}

return 0

