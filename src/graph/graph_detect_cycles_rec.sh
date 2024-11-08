. ./meta/meta.sh
((DEFENSE_VARIABLES[graph_detect_cycles_rec]++)) && return 0

. ./graph/graph_common.sh || return 1
. ./array/array_contains.sh || return 1
. ./array/array_index_of.sh || return 1

# 迭代深度优先搜索检测环并打印所有环
# 1: 图的变量引用
graph_detect_cycles_rec ()
{
    set -- '
    local -A visitedN1=()   
    local -a stackN1=()
    local -a stack_sliceN1=()
    local -a cyclesN1=()
    local indexN1
    local nodeN1
    local eN1

    _graph_detect_cycles_rec_visit ()
    {
        local neighborN1
        local -a neighborsN1
        if array_contains stackN1 "$1" ; then
            array_index_of stackN1 indexN1 "$1"
            stack_sliceN1=("${stackN1[@]:indexN1}")
            cyclesN1+=("(${stack_sliceN1[*]@Q})")
            return
        fi
        if [[ "${visitedN1[$1]:+set}" ]] ; then
            return
        fi
        visitedN1[$1]=1
        stackN1+=("$1")

        eval neighborsN1=${N1[$1]}
        for neighborN1 in "${neighborsN1[@]}" ; do
            _graph_detect_cycles_rec_visit "$neighborN1"
        done
        
        unset -v '\''stackN1[-1]'\''
    }

    for nodeN1 in "${!N1[@]}" ; do
        _graph_detect_cycles_rec_visit "$nodeN1"
    done

    if (( ${#cyclesN1[@]} )) ; then
        echo "Detected Rings: "
        for eN1 in "${cyclesN1[@]}"; do
            echo "$eN1"
        done
        return ${GRAPH_COMMON_ERR_DEFINE[ring_exist]}
    else
        echo "The graph does not exist rings."
        return ${GRAPH_COMMON_ERR_DEFINE[ok]}
    fi
    ' "${@}"
    eval -- "${1//N1/$2}"
}

return 0

