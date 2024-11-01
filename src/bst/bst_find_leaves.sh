. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_find_leaves]++)) && return 0


# 找出所有的叶子节点的节点ID保存到集合(关联数组)中
bst_find_leaves () 
{
    local -n _bst_find_leaves_tree_ref=$1 
    local -n _bst_find_leaves_leaves_set_ref=$2
    local _bst_find_leaves_queue=("$3")
    local _bst_find_leaves_current=
    _bst_find_leaves_leaves_set_ref=()

    while ((${#_bst_find_leaves_queue[@]})) ; do
        _bst_find_leaves_current=${_bst_find_leaves_queue[0]}
        _bst_find_leaves_queue=("${_bst_find_leaves_queue[@]:1}")

        # 判断是否是叶子
        if ((_bst_find_leaves_tree_ref[${_bst_find_leaves_current}.left]|
            _bst_find_leaves_tree_ref[${_bst_find_leaves_current}.right])) ; then
            ((_bst_find_leaves_tree_ref[${_bst_find_leaves_current}.left])) &&
            _bst_find_leaves_queue+=(
                "${_bst_find_leaves_tree_ref[${_bst_find_leaves_current}.left]}")
            ((_bst_find_leaves_tree_ref[${_bst_find_leaves_current}.right])) &&
            _bst_find_leaves_queue+=(
                "${_bst_find_leaves_tree_ref[${_bst_find_leaves_current}.right]}")
        else
            _bst_find_leaves_leaves_set_ref[$_bst_find_leaves_current]=1
        fi
    done
}

return 0

