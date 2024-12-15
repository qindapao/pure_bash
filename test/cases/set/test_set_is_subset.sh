#!/usr/bin/bash

_test_set_is_subset_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./set/set_is_subset.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_set_is_subset_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local -a get_arr=()
    local -a ret_spec_arr=(0 1 0)
    local -A set1=(['xgge geg']=1 ['x123 344']=1 ['x  ']=1 ['x']=1 ['x2']=1 ['x3']=1)
    local -A set2=(['xgge geg']=1 ['x']=1 ['x2']=1 ['x3']=1)
    local -A set3=(['xge geg']=1 ['x']=1 ['x2']=1 ['x3']=1)
    local -A set4=()
    set_is_subset set1 set2
    get_arr+=("$?")
    set_is_subset set1 set3
    get_arr+=("$?")
    set_is_subset set1 set4
    get_arr+=("$?")

    if [[ "${get_arr[*]}" == "${ret_spec_arr[*]}" ]] ; then
        echo "${FUNCNAME[0]} test pass"
    else
        echo "${FUNCNAME[0]} test fail"
        return 1
    fi

    return 0
}

test_case1

