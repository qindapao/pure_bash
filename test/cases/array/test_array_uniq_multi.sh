#!/usr/bin/bash

_test_array_uniq_multi_old_dir="$PWD"
root_dir="${_test_array_uniq_multi_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_uniq_multi.sh || return 1
. ./bit/bit_set.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_uniq_multi_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local ret=0
    local array=([100]=123 [105]=123 123 '456' 123 122 ' xo' '' '')
    local array1=('xx' 'oo' 'xx' 1 1 2 3 2 2 5 '' xxg '')
    local array2=(334 'xxui' 334 56 334 'xxui' 1 '' 123 '')
    local array_after=(123 456 122 ' xo' '')
    local array_after1=('xx' 'oo' 1 2 3 5 '' xxg)
    local array_after2=(334 'xxui' 56 1 '' 123)
    array_uniq_multi array array1 array2

    assert_array 'a' array array_after ; bit_set ret 0 $?
    assert_array 'a' array1 array_after1 ; bit_set ret 1 $?
    assert_array 'a' array2 array_after2 ; bit_set ret 2 $?

    if ((ret)) ; then
        echo "${FUNCNAME[0]} test fail."
    else
        echo "${FUNCNAME[0]} test pass."
    fi

    return $ret
}

test_case1

