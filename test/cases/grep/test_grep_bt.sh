#!/usr/bin/bash

_test_grep_bt_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./grep/grep_bt.sh || return 1
. ./atom/atom_func_uparr.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_grep_bt_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local test_str1='<mac>040341</mac>xgge<mac>0403102*02</mac><mac>*</mac>'
    local -a result_arr=()
    atom_func_uparr result_arr \
        grep_bt '<mAc>' '</mac>' "$test_str1" 1 1
    local -a after_arr=('040341' '0403102*02' '*')
    if assert_array 'a' result_arr after_arr ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local test_str1='<mac>040341</mac>xgge<mac>0403102*02</mac><mac>*</mac>'
    local tmp_file=$(mktemp)
    echo "$test_str1" >"$tmp_file"
    local -a result_arr=()
    atom_func_uparr result_arr \
        grep_bt '<mAc>' '</mac>' "$tmp_file" 1 0
    local -a after_arr=('040341' '0403102*02' '*')

    rm -f "$tmp_file"

    if assert_array 'a' result_arr after_arr ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case2

