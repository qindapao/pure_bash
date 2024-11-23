#!/usr/bin/bash

_test_array_qsort_old_dir="$PWD"
root_dir="${_test_array_qsort_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_qsort.sh || return 1
. ./array/array_sort.sh || return 1
. ./cntr/cntr_copy.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_qsort_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv
# :TODO: 其它的比较参数的用例
# :TODO: 所有数组比较的地方都把冒泡排序换成快速排序

test_case1 ()
{
    local -a array_after1=()
    local -a array_after2=()
    local array=(
        1 16 8 5 6 34 293 3321 111 1 10 101 758 2033
    )

    array_qsort array '-gt'
    cntr_copy array_after1 array
    local array=(
        1 16 8 5 6 34 293 3321 111 1 10 101 758 2033
    )
    array_sort array '-gt'
    cntr_copy array_after2 array

    if assert_array 'a' array_after1 array_after2 ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local -a array=(
        [100]=90 [103]=1 [600]=45 [13]=17 [79]=1000 [5]=91
    )
    local -a array_after=(
        [5]="1" [13]="17" [79]="45" [100]="90" [103]="91" [600]="1000"
    )

    array_qsort array '-gt'
    if assert_array 'a' array array_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case2

