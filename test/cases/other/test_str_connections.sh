#!/usr/bin/bash

_test_str_connections_old_dir="$PWD"
root_dir="${_test_str_connections_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_connections_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_disable ()
{
    echo "${FUNCNAME[0]} test is disabled."
}

test_case1 ()
{
    _bst_insert_recycle_ids=' 0 89 100'
    time for ((i=0;i<1000000;i++)) ; do
        _bst_insert_recycle_ids+=" $i"
    done
    time _bst_insert_recycle_ids+=" $i"

    _bst_insert_node_id=${_bst_insert_recycle_ids##* }
    _bst_insert_recycle_ids=${_bst_insert_recycle_ids% *}
    # declare -p _bst_insert_node_id _bst_insert_recycle_ids

    _bst_insert_node_id=${_bst_insert_recycle_ids##* }
    _bst_insert_recycle_ids=${_bst_insert_recycle_ids% *}
    # declare -p _bst_insert_node_id _bst_insert_recycle_ids

    _bst_insert_node_id=${_bst_insert_recycle_ids##* }
    _bst_insert_recycle_ids=${_bst_insert_recycle_ids% *}
    # declare -p _bst_insert_node_id _bst_insert_recycle_ids
}

test_disable
exit $?
test_case1

