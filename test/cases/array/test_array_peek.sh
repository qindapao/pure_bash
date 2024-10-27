#!/usr/bin/bash

_test_array_peek_old_dir="$PWD"
root_dir="${_test_array_peek_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_peek.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_peek_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local array1=('0 x' 1 2 3)
    local array2=([100]='5 x' xx yy)
    local str1 str2
    str1=$(array_peek array1)
    str2=$(array_peek array2)
    if [[ "$str1" == '0 x' ]] && [[ "$str2" == '5 x' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

