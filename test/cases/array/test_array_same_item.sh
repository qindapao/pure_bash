#!/usr/bin/bash

_test_array_same_item_old_dir="$PWD"
root_dir="${_test_array_same_item_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_same_item.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_same_item_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local array=()
    local array_after=(' xxx yk' ' xxx yk' ' xxx yk' ' xxx yk' ' xxx yk')
    array_same_item array ' xxx yk' 5
    if assert_array 'a' array array_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

