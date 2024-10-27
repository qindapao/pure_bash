#!/usr/bin/bash

_test_array_last_i_old_dir="$PWD"
root_dir="${_test_array_last_i_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_last_i.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_last_i_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local last_i
    local array=([0]=1 [100]=2 [104]=5)
    array_last_i array last_i
    if [[ "$last_i" == '104' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

