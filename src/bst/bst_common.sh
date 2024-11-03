. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_common]++)) && return 0

declare -gA BST_COMMON_ERR_DEFINE=()

# 每一种操作留8个状态码
# insert 8~15
# del 16~23

BST_COMMON_ERR_DEFINE[ok]=0


# 插入一个空树
BST_COMMON_ERR_DEFINE[insert_null_tree]=8
# 插入重复元素
BST_COMMON_ERR_DEFINE[insert_same_e]=9

# 删除的节点未找到
BST_COMMON_ERR_DEFINE[del_not_found]=16
# 删除的节点是根节点
BST_COMMON_ERR_DEFINE[del_root_node]=17

return 0

