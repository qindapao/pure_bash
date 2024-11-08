#!/usr/bin/bash

_test_bst_old_dir="$PWD"
root_dir="${_test_bst_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

. ./bst/bst_init.sh || return 1
. ./bst/bst_insert.sh || return 1
. ./bst/bst_lot.sh || return 1
. ./bst/bst_it.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_bst_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv


test_case1 ()
{
    local -A bst
    local root_id out_id

    bst_init bst root_id '20'
    bst_insert bst $root_id out_id 21
    bst_insert bst $root_id out_id 5
    bst_insert bst $root_id out_id 3
    bst_insert bst $root_id out_id 2
    bst_insert bst $root_id out_id 25
    bst_insert bst $root_id out_id 24
    bst_insert bst $root_id out_id 30

    bst_it bst $root_id
    bst_lot bst $root_id
}

test_case1

