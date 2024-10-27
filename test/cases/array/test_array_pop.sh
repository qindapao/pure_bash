#!/usr/bin/bash

_test_array_pop_old_dir="$PWD"
root_dir="${_test_array_pop_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_pop.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_pop_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local array1=('0 x' 1 2 3)
    local array2=([100]='5 x' xx yy)
    local str1 str2
    local array1_after=('0 x' 1 2)
    local array2_after=([100]='5 x' xx)

    array_pop array1 str1
    array_pop array2 str2

    if [[ "$str1" == '3' ]] && [[ "$str2" == 'yy' ]] &&
        assert_array 'a' array1 array1_after &&
        assert_array 'a' array2 array2_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

