. ./meta/meta.sh
((DEFENSE_VARIABLES[graph_add_edge]++)) && return 0

. ./graph/graph_common.sh || return 1

# 添加边
graph_add_edge () 
{
    local -n _graph_add_edge_ref=$1
    local _graph_add_edge_from=$2
    local _graph_add_edge_to=$3
    local -a _graph_add_edge_neighbors
    local _graph_add_edge_tmp
    
    if ! [[ "${_graph_add_edge_ref[$_graph_add_edge_from]:+set}" ]] ; then
        echo "start node ${_graph_add_edge_from} is not exist!" >&2
        return ${GRAPH_COMMON_ERR_DEFINE[node_not_exist]}
    fi
    if ! [[ "${_graph_add_edge_ref[$_graph_add_edge_to]:+set}" ]] ; then
        echo "end node ${_graph_add_edge_to} is not exist!" >&2
        return ${GRAPH_COMMON_ERR_DEFINE[node_not_exist]}
    fi

    eval _graph_add_edge_neighbors=${_graph_add_edge_ref[$_graph_add_edge_from]}
    _graph_add_edge_neighbors+=("$_graph_add_edge_to")
    printf -v _graph_add_edge_tmp "(%s)" "${_graph_add_edge_neighbors[*]@Q}"
    _graph_add_edge_ref[$_graph_add_edge_from]=$_graph_add_edge_tmp

    return ${GRAPH_COMMON_ERR_DEFINE[ok]}
}

return 0

