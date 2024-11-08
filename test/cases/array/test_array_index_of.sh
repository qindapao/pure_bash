#!/usr/bin/bash

_test_array_index_of_old_dir="$PWD"
root_dir="${_test_array_index_of_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_index_of.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_index_of_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local array1=([100]=' xo' [101]=1 [102]=6 [109]='10 2')
    local -i index
    local ret

    array_index_of array1 index '10 2'
    ret=$?
    if [[ "$ret" == '0' && "$index" == '109' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test pass."
        return 1
    fi
}

test_case2 ()
{
    local array1=(1 2 3 4 'xo' 'gg' 'kk' 'xo')
    local -i index
    local ret

    array_index_of array1 index 'xo'
    ret=$?
    if [[ "$ret" == '0' && "$index" == '4' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test pass."
        return 1
    fi
}

test_case3 ()
{
    local array1=(1 2 3 4 'xo' 'gg' 'kk' 'xo')
    local -i index
    local ret

    array_index_of array1 index 'tutu'
    ret=$?
    if [[ "$ret" == '1' && "$index" == '-1' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test pass."
        return 1
    fi
}

test_case1 &&
test_case2 &&
test_case3

