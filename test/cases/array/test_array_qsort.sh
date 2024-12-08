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

test_case3 ()
{
    local mork_func=$(declare -f array_qsort)
    local array=()
    local array_after=()
    local ret=0
    local -i sub_case=1
    # 重新定义函数
    local array=(90 98 90 8 9 1 10 19 13 8 10009 56)
    local array_after=([0]="1" [1]="8" [2]="8" [3]="9" [4]="10" [5]="13" [6]="19" [7]="56" [8]="90" [9]="90" [10]="98" [11]="10009")
    eval "${mork_func}"
    array_qsort array '-gt'
    assert_array 'a' array_after array
    (($?)) && { echo "${FUNCNAME[0]} $((sub_case++)) test fail." ; return 1; } || echo "${FUNCNAME[0]} $((sub_case++)) test pass."

    local array=(90 98 90 8 9 1 10 19 13 8 10009 56)
    eval "${mork_func//100/0}"
    array_qsort array '-gt'
    assert_array 'a' array_after array
    (($?)) && { echo "${FUNCNAME[0]} $((sub_case++)) test fail." ; return 1; } || echo "${FUNCNAME[0]} $((sub_case++)) test pass."

    local array=(90 98 90 8 9 1 10 19 13 8 10009 56)
    local array_after=([0]="10009" [1]="98" [2]="90" [3]="90" [4]="56" [5]="19" [6]="13" [7]="10" [8]="9" [9]="8" [10]="8" [11]="1")
    eval "${mork_func}"
    array_qsort array '-lt'
    assert_array 'a' array_after array
    (($?)) && { echo "${FUNCNAME[0]} $((sub_case++)) test fail." ; return 1; } || echo "${FUNCNAME[0]} $((sub_case++)) test pass."

    local array=(90 98 90 8 9 1 10 19 13 8 10009 56)
    local array_after=([0]="10009" [1]="98" [2]="90" [3]="90" [4]="56" [5]="19" [6]="13" [7]="10" [8]="9" [9]="8" [10]="8" [11]="1")
    eval "${mork_func//100/0}"
    array_qsort array '-lt'
    assert_array 'a' array_after array
    (($?)) && { echo "${FUNCNAME[0]} $((sub_case++)) test fail." ; return 1; } || echo "${FUNCNAME[0]} $((sub_case++)) test pass."

    local array=('dxgg ge10 1' '' ' ' '
    eg' 'dge7*)L' '*)(dgge)'  '9029' 1 2 3 4 'xx oo')
    local array_after=([0]=$'\n    eg' [1]=" " [2]="" [3]="*)(dgge)" [4]="1" [5]="2" [6]="3" [7]="4" [8]="9029" [9]="dge7*)L" [10]="dxgg ge10 1" [11]="xx oo")
    eval "${mork_func}"
    array_qsort array
    assert_array 'a' array_after array
    (($?)) && { echo "${FUNCNAME[0]} $((sub_case++)) test fail." ; return 1; } || echo "${FUNCNAME[0]} $((sub_case++)) test pass."

    local array=('dxgg ge10 1' '' ' ' '
    eg' 'dge7*)L' '*)(dgge)'  '9029' 1 2 3 4 'xx oo')
    eval "${mork_func//100/0}"
    array_qsort array
    assert_array 'a' array_after array
    (($?)) && { echo "${FUNCNAME[0]} $((sub_case++)) test fail." ; return 1; } || echo "${FUNCNAME[0]} $((sub_case++)) test pass."

    local array=('dxgg ge10 1' '' ' ' '
    eg' 'dge7*)L' '*)(dgge)'  '9029' 1 2 3 4 'xx oo')
    local array_after=([0]=$'\n    eg' [1]=" " [2]="" [3]="*)(dgge)" [4]="1" [5]="2" [6]="3" [7]="4" [8]="9029" [9]="dge7*)L" [10]="dxgg ge10 1" [11]="xx oo")
    eval "${mork_func}"
    array_qsort array '>'
    assert_array 'a' array_after array
    (($?)) && { echo "${FUNCNAME[0]} $((sub_case++)) test fail." ; return 1; } || echo "${FUNCNAME[0]} $((sub_case++)) test pass."

    local array=('dxgg ge10 1' '' ' ' '
    eg' 'dge7*)L' '*)(dgge)'  '9029' 1 2 3 4 'xx oo')
    eval "${mork_func//100/0}"
    array_qsort array '>'
    assert_array 'a' array_after array
    (($?)) && { echo "${FUNCNAME[0]} $((sub_case++)) test fail." ; return 1; } || echo "${FUNCNAME[0]} $((sub_case++)) test pass."

    local array=('dxgg ge10 1' '' ' ' '
    eg' 'dge7*)L' '*)(dgge)'  '9029' 1 2 3 4 'xx oo')
    local array_after=([0]="xx oo" [1]="dxgg ge10 1" [2]="dge7*)L" [3]="9029" [4]="4" [5]="3" [6]="2" [7]="1" [8]="*)(dgge)" [9]="" [10]=" " [11]=$'\n    eg')
    eval "${mork_func}"
    array_qsort array '<'
    assert_array 'a' array_after array
    (($?)) && { echo "${FUNCNAME[0]} $((sub_case++)) test fail." ; return 1; } || echo "${FUNCNAME[0]} $((sub_case++)) test pass."

    local array=('dxgg ge10 1' '' ' ' '
    eg' 'dge7*)L' '*)(dgge)'  '9029' 1 2 3 4 'xx oo')
    eval "${mork_func//100/0}"
    array_qsort array '<'
    assert_array 'a' array_after array
    (($?)) && { echo "${FUNCNAME[0]} $((sub_case++)) test fail." ; return 1; } || echo "${FUNCNAME[0]} $((sub_case++)) test pass."
}


test_case1 &&
test_case2 &&
test_case3

