#!/usr/bin/bash

_test_graph_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./graph/graph_add_node.sh || return 1
. ./graph/graph_add_edge.sh || return 1
. ./graph/graph_detect_cycles_rec.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_graph_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    # 示例用法
    local -A graph
    graph_add_node graph 1 2 3 4 5 6 7
    graph_add_edge graph 1 2
    graph_add_edge graph 2 3
    graph_add_edge graph 3 1  # 形成一个环
    graph_add_edge graph 2 4
    graph_add_edge graph 4 5
    graph_add_edge graph 4 8
    graph_add_edge graph 5 2  # 形成另一个环

    graph_detect_cycles_rec graph
    declare -p graph
}

test_case2 ()
{
    # 示例用法
    local -A graph
    graph_add_node graph '1 a' 2 3 4 5 6 7
    graph_add_edge graph '1 a' 2
    graph_add_edge graph 2 3
    graph_add_edge graph 3 '1 a'  # 形成一个环
    graph_add_edge graph 2 4
    graph_add_edge graph 4 5
    graph_add_edge graph 4 8
    graph_add_edge graph 5 2  # 形成另一个环

    graph_detect_cycles_rec graph
}

test_case1 &&
test_case2

