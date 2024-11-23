. ./meta/meta.sh
((DEFENSE_VARIABLES[graph_detect_cycles_rec]++)) && return 0

# :TODO: 验证发现这个函数有BUG,因为关联数组的键排序规则居然会影响
# 最终的检测到的环的结果,所以这个函数是有问题的

. ./graph/graph_common.sh || return 1
. ./array/array_contains.sh || return 1
. ./array/array_index_of.sh || return 1
. ./array/array_qsort.sh || return 1

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
            # echo "Cycle detected: (${stack_sliceN1[*]@Q})"
            return
        fi
        if [[ "${visitedN1[$1]:+set}" ]] ; then
            return
        fi
        visitedN1[$1]=1
        stackN1+=("$1")
        # echo "Visiting node: $1, Stack: ${stackN1[*]}"

        eval neighborsN1=${N1[$1]}
        for neighborN1 in "${neighborsN1[@]}" ; do
            _graph_detect_cycles_rec_visit "$neighborN1"
        done
        
        unset -v '\''stackN1[-1]'\''
        # echo "Backtracking from node: $1, Stack: ${stackN1[*]}"
    }
    
    # 关联数组的键排序影响了最终的结果,所以环检测函数有BUG
    # 在bash5.2直接能得出结果,但是在bash4.4上结果不对,发现是键的排序影响了
    # 这显然不合理
    local -a key_array_N1=()
    key_array_N1=("${!N1[@]}")
    array_qsort key_array_N1

    for nodeN1 in "${key_array_N1[@]}" ; do
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

