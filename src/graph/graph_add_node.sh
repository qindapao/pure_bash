. ./meta/meta.sh
((DEFENSE_VARIABLES[graph_add_node]++)) && return 0

. ./graph/graph_common.sh || return 1

# 添加边
graph_add_node () 
{
    local -n _graph_add_node_graph=$1
    shift
    local _graph_add_node_nodes=("$@")
    local _graph_add_node_node
    local _graph_add_node_ret=${GRAPH_COMMON_ERR_DEFINE[ok]}
    # 初始化节点,没有邻居
    for _graph_add_node_node in "${_graph_add_node_nodes[@]}" ; do
        if ! [[ "${_graph_add_node_graph[$_graph_add_node_node]:+set}" ]] ; then
            _graph_add_node_graph[$_graph_add_node_node]='()'
        else
            echo 'node:{_graph_add_node_node} is exsit!' >&2
            _graph_add_node_ret=${GRAPH_COMMON_ERR_DEFINE[node_repeat]}
        fi
    done

    return $_graph_add_node_ret
}

return 0

