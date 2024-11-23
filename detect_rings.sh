#! /usr/bin/bash

cd ./src
. ./graph/graph_add_edge.sh || return 1
. ./graph/graph_add_node.sh || return 1
. ./graph/graph_detect_cycles_rec.sh || return 1
. ./file/file_traverse.sh || return 1
. ./cntr/cntr_grep.sh || return 1
. ./str/str_basename.sh || return 1
. ./array/array_read_file.sh || return 1

# set -xv
# BUG: :TODO: 受不同bash版本键的顺序的影响,所以有问题
detect_rings ()
{
    local -A func_graph
    local -a funcs=() func_content=()
    local func func_name func_line point_func_name
    # 获取所有源码文件
    set -- "$IFS" ; local IFS=$'\n' ; funcs=($(file_traverse '.')) ; IFS="$1"
    cntr_grep funcs '[[ "$1" == *".sh" ]]'
    for func in "${funcs[@]}" ; do
        func_name=$func ; str_basename func_name
        graph_add_node func_graph "$func_name"
    done

    echo "all nodes num:${#func_graph[@]}"
    local -i edge_num=0

    for func in "${funcs[@]}" ; do
        func_name=$func ; str_basename func_name
        func_content=() ; array_read_file func_content "$func"
    
        for func_line in "${func_content[@]}" ; do
            if [[ "$func_line" =~ ^\.\ +([^| ]+\.sh) ]] ; then
                point_func_name=${BASH_REMATCH[1]} ; str_basename point_func_name
                graph_add_edge func_graph "$func_name" "$point_func_name"
                ((edge_num++))
            fi
        done
    done

    echo "all edges num:${edge_num}"
    graph_detect_cycles_rec func_graph
}

detect_rings

