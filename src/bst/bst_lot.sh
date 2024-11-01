. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_lot]++)) && return 0

# 层序遍历打印二叉树(只打印节点的ID,不打印节点的值)
# 并且按照层级打印
# lot: Level Order Traversal(Breadth-first Traversal)
bst_lot () 
{
    local -n _bst_lot_tree_ref=$1
    local _bst_lot_queue=("$2")
    local _bst_lot_current
    local _bst_lot_cur_lev_cnt=1
    local _bst_lot_next_lev_cnt=0
    local -i _bst_lot_i=0
    # 所有层的节点
    local -a _bst_lot_levs=()
    # 某层的节点
    local -a _bst_lot_lev=()

    while ((${#_bst_lot_queue[@]})) ; do
        _bst_lot_lev=()
        for ((_bst_lot_i=0;_bst_lot_i<_bst_lot_cur_lev_cnt;_bst_lot_i++)) ; do
            _bst_lot_current=${_bst_lot_queue[0]}
            _bst_lot_queue=("${_bst_lot_queue[@]:1}")
            _bst_lot_lev+=("$_bst_lot_current")
            ((_bst_lot_tree_ref[${_bst_lot_current}.left])) && {
                _bst_lot_queue+=("${_bst_lot_tree_ref[${_bst_lot_current}.left]}")
                ((_bst_lot_next_lev_cnt++))
            }
            ((_bst_lot_tree_ref[${_bst_lot_current}.right])) && {
                _bst_lot_queue+=("${_bst_lot_tree_ref[${_bst_lot_current}.right]}")
                ((_bst_lot_next_lev_cnt++))
            }
        done
        # 压入到总层数组
        _bst_lot_levs+=("(${_bst_lot_lev[*]})")
        _bst_lot_cur_lev_cnt=$_bst_lot_next_lev_cnt
        _bst_lot_next_lev_cnt=0
    done

    printf "%s\n" "${_bst_lot_levs[@]}" 
    printf "idcount=%s\n" "${_bst_lot_tree_ref[idcount]}"
    printf "recycle_ids=%s\n" "${_bst_lot_tree_ref[recycle_ids]}"
}

return 0

