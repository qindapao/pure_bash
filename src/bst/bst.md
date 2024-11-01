# bst

bst是Binary Search Tree的缩写

## bst模块中备份的函数

### bst_fdft_rec

树状打印一颗二叉树当前已经有迭代的实现，递归的实现备份起来。

```bash
. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_fdft_rec]++)) && return 0


# fdft: Formatted Depth-First Traversal(格式化深度优先遍历)
# 当前的顺序是左树在下面,右树在上面
# 如果想要调整顺序把代码中的三个 .right 换成 .left
#                           三个 .left  换成 .right
#                           即可,代码的其它部分都不需要改动!
#                ┌──>8(8)
#                |
#            ┌──>6(6)
#            |   └──>7(7)
#            |
#            |
#        ┌──>4(4)
#        |   |
#        |   |   ┌──>10(10)
#        |   └──>9(9)
#        |       |
#        |       |
#        |       |   ┌──>12(12)
#        |       └──>11(11)
#        |           |
#        |           |
#        |           |   ┌──>14(14)
#        |           └──>13(13)
#        |               |
#        |               └──>15(15)
#        |
#|── root(value1)
#        |
#        |   ┌──>3(3)
#        └──>1(1)
#            |
#            └──>2(2)
#
bst_fdft_rec () 
{
    local -n _bst_fdft_rec_tree_ref=$1
    local _bst_fdft_rec_node=$2
    local _bst_fdft_rec_indent=$3
    local _bst_fdft_rec_is_left=$4
    # 一定不能在递归调用的时候更新这个变量
    local _bst_fdft_rec_pre=$5
    local _bst_fdft_rec_pre_new=
    local _bst_fdft_rec_has_r_child=$6
    local _bst_fdft_rec_has_l_child=$7

    if ((_bst_fdft_rec_tree_ref[${_bst_fdft_rec_node}.right])) ; then
        if ((_bst_fdft_rec_has_r_child)) ; then
            _bst_fdft_rec_pre_new="${_bst_fdft_rec_pre}    "
        else
            _bst_fdft_rec_pre_new="${_bst_fdft_rec_pre}|   "
        fi
        bst_fdft_rec "$1" "${_bst_fdft_rec_tree_ref[${_bst_fdft_rec_node}.right]}" "$((_bst_fdft_rec_indent+1))" \
            1 "$_bst_fdft_rec_pre_new" 1 0
    fi
    
    if [[ "$_bst_fdft_rec_is_left" == '1' ]] ; then
        if ((_bst_fdft_rec_tree_ref[${_bst_fdft_rec_node}.right])) ; then
            printf "%s%*s%s\n" "$_bst_fdft_rec_pre" 4 ' ' '|   '
        else
            printf "%s\n" "$_bst_fdft_rec_pre"
        fi
        printf "%s%s%s(%q)\n" "$_bst_fdft_rec_pre" '┌──>' "$_bst_fdft_rec_node" "${_bst_fdft_rec_tree_ref[${_bst_fdft_rec_node}.value]}"
    elif [[ "$_bst_fdft_rec_is_left" == '0' ]] ; then
        printf "%s%s%s(%q)\n" "$_bst_fdft_rec_pre" '└──>' "$_bst_fdft_rec_node" "${_bst_fdft_rec_tree_ref[${_bst_fdft_rec_node}.value]}"
        if ((_bst_fdft_rec_tree_ref[${_bst_fdft_rec_node}.left])) ; then
            printf "%s%*s%s\n" "$_bst_fdft_rec_pre" 4 ' ' '|   '
        else
            printf "%s\n" "$_bst_fdft_rec_pre"
        fi
    else
        printf "%s%s(%q)\n" '|── ' "$_bst_fdft_rec_node" "${_bst_fdft_rec_tree_ref[${_bst_fdft_rec_node}.value]}"
    fi
    
    if ((_bst_fdft_rec_tree_ref[${_bst_fdft_rec_node}.left])) ; then
        if ((_bst_fdft_rec_has_l_child)) ; then
            _bst_fdft_rec_pre_new="${_bst_fdft_rec_pre}    "
        else
            _bst_fdft_rec_pre_new="${_bst_fdft_rec_pre}|   "
        fi
        bst_fdft_rec "$1" "${_bst_fdft_rec_tree_ref[${_bst_fdft_rec_node}.left]}" "$((_bst_fdft_rec_indent+1))" \
            0 "$_bst_fdft_rec_pre_new" 0 1
    fi

    # printf "idcount=%s\n" "${_bst_fdft_rec_tree_ref[idcount]}"
    # printf "recycle_ids=%s\n" "${_bst_fdft_rec_tree_ref[recycle_ids]}"
}

return 0
```

### 竖向打印的原始实现

https://stackoverflow.com/questions/34012886/print-binary-tree-level-by-level-in-python

```python3
def print_tree(self, indent=0, is_left=None, prefix='    ', has_right_child=True, has_left_child=True):
      if self.left:
          self.left.print_tree(indent + 1, True, prefix + ('    ' if has_right_child else '|   '), has_right_child=True, has_left_child=False)
      if is_left == True:
          if self.left:
            print(prefix + f'd={self.depth}' + ' |   ')
          else:
            print(prefix + f'd={self.depth}' )
          print(prefix +  '┌──>' + str(self.value))
      elif is_left == False:
          print(prefix  + '└──>' + str(self.value))
          if self.right:
            print(prefix + f'd={self.depth}' + ' |   ')
          else:
            print(prefix + f'd={self.depth}' )
      else:
          print('|── ' + str(self.value))

      if self.right:
          self.right.print_tree(indent + 1, False, prefix + ('    ' if has_left_child else '|   '), has_right_child=False, has_left_child=True)

class Node:
    # Classic Node class with left, right and value, depth is Optional
    def __init__(self, value=None, left=None, right=None, depth=None):
        self.value = value
        self.left = left
        self.right = right
        self.depth = depth
```

打印出来是这样的格式：

```txt
        d=1
        ┌──>1 
    |── 0
        |   d=2
        |   ┌──>156
        └──>23
        d=1 |   
            |   d=3
            |   ┌──>213
            └──>321
            d=2 |   
                |   d=4
                |   ┌──>245
                └──>123
                d=3 |   
                    └──>123
                    d=4
```

作者之所以在打印的部分写得那么复杂，主要就是为了打印那个深度属性。不然的话，根据 
三种条件简单打印一行即可。



## 多叉树的构思

```bash
mtt_init() {
    local -n _mtt_init_tree_ref=$1
    local _mtt_init_root_value=$2
    _mtt_init_tree_ref[root.children]='()'
    _mtt_init_tree_ref[root.value]=$_mtt_init_root_value
    _mtt_init_tree_ref[root.parent]=0
    _mtt_init_tree_ref[idcount]=1
    _mtt_init_tree_ref[recycle_ids]='()'
}

### 插入节点
mtt_insert() {
    local -n _mtt_insert_tree_ref=$1
    local _mtt_insert_parent=$2
    local _mtt_insert_value=$3
    local _mtt_insert_node_id=

    if [[ "${_mtt_insert_tree_ref[recycle_ids]}" != '()' ]]; then
        eval _mtt_insert_recycle_ids=${_mtt_insert_tree_ref[recycle_ids]}
        _mtt_insert_node_id=${_mtt_insert_recycle_ids[-1]}
        unset -v _mtt_insert_recycle_ids[-1]
        _mtt_insert_tree_ref[recycle_ids]="(${_mtt_insert_recycle_ids[*]})"
    else
        _mtt_insert_node_id=$((_mtt_insert_tree_ref[idcount]++))
    fi

    _mtt_insert_tree_ref[${_mtt_insert_node_id}.children]='()'
    _mtt_insert_tree_ref[${_mtt_insert_node_id}.value]=$_mtt_insert_value
    _mtt_insert_tree_ref[${_mtt_insert_node_id}.parent]=$_mtt_insert_parent

    local -a _parent_children
    eval _parent_children=${_mtt_insert_tree_ref[${_mtt_insert_parent}.children]}
    _parent_children+=("$_mtt_insert_node_id")
    _mtt_insert_tree_ref[${_mtt_insert_parent}.children]="(${_parent_children[*]})"
}

### 打印多叉树
mtt_print() {
    local -n _mtt_print_tree_ref=$1
    local _mtt_print_node=$2
    local _mtt_print_indent=$3

    printf "%*s%s\n" $((_mtt_print_indent * 4)) "" "${_mtt_print_tree_ref[${_mtt_print_node}.value]}"
    local -a _children
    eval _children=${_mtt_print_tree_ref[${_mtt_print_node}.children]}
    for child in "${_children[@]}"; do
        mtt_print _mtt_print_tree_ref "$child" $((_mtt_print_indent + 1))
    done
}

# 示例用法
declare -A mtt
mtt_init mtt "root"
mtt_insert mtt root "child1"
mtt_insert mtt root "child2"
mtt_insert mtt root "child3"
mtt_insert mtt 1 "child1.1"
mtt_insert mtt 1 "child1.2"
mtt_print mtt root 0
```

