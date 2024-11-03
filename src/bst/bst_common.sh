. ./meta/meta.sh
((DEFENSE_VARIABLES[bst_common]++)) && return 0

declare -gA BST_COMMON_ERR_DEFINE=()

# 每一种操作留8个状态码
# insert 8~15

BST_COMMON_ERR_DEFINE[ok]=0


# 插入一个空树
BST_COMMON_ERR_DEFINE[insert_null_tree]=8
# 插入重复元素
BST_COMMON_ERR_DEFINE[insert_same_e]=9


return 0
