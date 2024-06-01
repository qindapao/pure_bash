# 二叉树的操作函数集合,不知道有什么用
# 比较有趣吧,bash中玩二叉树

. ./meta/meta.sh
((DEFENSE_VARIABLES[binary_tree_todo]++)) && return 0



# # 二叉树节点的声明
# declare -A tree
# tree=( [root]=1 [1,left]=2 [1,right]=3 [2,left]=4 [2,right]=5 [3,left]=6 [3,right]=7 )
# 
# # 前序遍历函数
# preorder_traversal() {
#     local node=$1
#     [[ -z "$node" ]] && return  # 如果节点为空，返回
#     echo "访问节点: ${tree[$node]}"  # 访问节点
#     preorder_traversal "${node},left"  # 遍历左子树
#     preorder_traversal "${node},right"  # 遍历右子树
# }
# 
# # 开始前序遍历
# preorder_traversal root
# 
# # 如果节点有重复，可以通过设定节点的路径标识符来解决
# # 或者用一个ID来,可以算一个随机的hash值之类的?
# declare -A tree
# tree=( [root]=1 [1,left]=2 [1,right]=3 [2,left]=5 [2,right]=5 )
# tree_id=( [1]="root" [2]="1,left" [3]="1,right" [4]="2,left" [5]="2,right" )
# 
# # 访问值为5的节点
# echo "访问节点: ${tree_id[4]} 的值为 ${tree[2,left]}"
# echo "访问节点: ${tree_id[5]} 的值为 ${tree[2,right]}"

return 0

