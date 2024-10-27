#!/usr/bin/bash

_test_array_del_elements_dense_old_dir="$PWD"
root_dir="${_test_array_del_elements_dense_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_del_elements_dense.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_del_elements_dense_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 () 
{
    local array=('1 2' 'x 1' 'x
o' 4 5 6)
    local array_after=('1 2' 'x 1' 6)
    array_del_elements_dense array 'x
o' 4 5
    if assert_array 'a' array array_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

