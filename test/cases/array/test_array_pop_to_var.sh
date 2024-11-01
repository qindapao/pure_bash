#!/usr/bin/bash

_test_array_pop_to_var_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_pop_to_var.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_pop_to_var_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local array=(1 2 '3 4' 5 6 '7 8')
    local a1 a2 a3 a4 a5 a6
    array_pop_to_var a1 a2 a3 a4 a5 a6 array

    if [[ "$a1" == '7 8' ]] &&
        [[ "$a2" == '6' ]] &&
        [[ "$a3" == '5' ]] &&
        [[ "$a4" == '3 4' ]] &&
        [[ "$a5" == '2' ]] &&
        [[ "$a6" == '1' ]] &&
        assert_array 'a' array PURE_BASH_NULL_ARRAY ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

