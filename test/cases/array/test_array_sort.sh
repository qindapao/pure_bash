#!/usr/bin/bash

_test_array_sort_old_dir="$PWD"
root_dir="${_test_array_sort_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_sort.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_sort_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local -a a1=("10:7:5" "8:9:4" "11:2:6" "4:1:7")

    array_sort a1 '-gt' ':' 1

    local -a a2=("4:1:7" "8:9:4" "10:7:5" "11:2:6")
    if assert_array 'a' a1 a2 ; then
        echo "${FUNCNAME[0]} case 1 test pass"
    else
        echo "${FUNCNAME[0]} case 1 test fail"
    fi
    array_sort a1 '-gt' ':' 2
    local -a a2=("4:1:7" "11:2:6" "10:7:5" "8:9:4")
    if assert_array 'a' a1 a2 ; then
        echo "${FUNCNAME[0]} case 2 test pass"
    else
        echo "${FUNCNAME[0]} case 2 test fail"
    fi
}

test_case1

