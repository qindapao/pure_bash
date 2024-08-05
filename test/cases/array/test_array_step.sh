#!/usr/bin/bash

_test_array_step_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_step.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_step_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local a=(0 1 2 3 4 5 6 8)
    local b=(0 1 2 3 4 5 6 7 8 9 10)
    local a1=() a2=() a3=() b1=() b2=() b3=()

    local -a des_a1=([0]="0" [1]="1" [2]="2" [3]="3" [4]="4" [5]="5" [6]="6" [7]="8")
    local -a des_a2=([0]="0" [1]="2" [2]="4" [3]="6")
    local -a des_a3=([0]="1" [1]="3" [2]="5" [3]="8")
    local -a des_b1=([0]="0" [1]="3" [2]="6" [3]="9")
    local -a des_b2=([0]="1" [1]="4" [2]="7" [3]="10")
    local -a des_b3=([0]="2" [1]="5" [2]="8")

    local xxa=(01 02 03 04 05)
    local xxb=()

    local ret_str=''
    array_step a a1 0 1
    assert_array 'a' a1 des_a1
    ret_str+="$?|"
    array_step a a2 0 2
    assert_array 'a' a2 des_a2
    ret_str+="$?|"
    array_step a a3 1 2
    assert_array 'a' a3 des_a3
    ret_str+="$?|"
        
    array_step b b1 0 3
    assert_array 'a' b1 des_b1
    ret_str+="$?|"
    array_step b b2 1 3
    assert_array 'a' b2 des_b2
    ret_str+="$?|"
    array_step b b3 2 3
    assert_array 'a' b3 des_b3
    ret_str+="$?"

    array_step xx{a,b} 0 2

    if ! ((ret_str)) ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
    return 0
}

test_case1

