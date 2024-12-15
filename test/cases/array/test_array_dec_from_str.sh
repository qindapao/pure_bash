#!/usr/bin/bash

_test_array_dec_from_str_old_dir="$PWD"
root_dir="${_test_array_dec_from_str_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_dec_from_str.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_dec_from_str_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local str="0 1dgg ( 10 15 67 ) 1000 (90)"
    local -a str_arr=()
    local -a str_arr_after=(0 1 10 15 67 1000 90)
    array_dec_from_str str_arr "$str"
    if assert_array 'a' str_arr str_arr_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local str='xx oo 123 (gg1000  gge)
geg843744 geg10 101 01 01 23'
    local -a str_arr=()
    local -a str_arr_after=(123 1000 843744 10 101 01 01 23)
    array_dec_from_str str_arr "$str"
    if assert_array 'a' str_arr str_arr_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
    
}

test_case1 &&
test_case2

