. ./meta/meta.sh
((DEFENSE_VARIABLES[graph_common]++)) && return 0

GRAPH_COMMON_ERR_DEFINE[ok]=0

# node 8~15
GRAPH_COMMON_ERR_DEFINE[node_repeat]=8
GRAPH_COMMON_ERR_DEFINE[node_not_exist]=9

# 环检测 16~13
GRAPH_COMMON_ERR_DEFINE[ring_exist]=16

return 0

