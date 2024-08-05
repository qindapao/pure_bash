#!/usr/bin/bash

_test_array_same_sitem_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_same_sitem.sh || return 1
. ./array/array_same_item.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_same_sitem_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local a1=() a2=()
    array_same_sitem a1 '1 x gge
    ge gge' 500
    array_same_item a2 '1 x gge
    ge gge' 500
    if assert_array 'a' a1 a2 ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
    
    return 0
}

test_case1

