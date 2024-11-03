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













