#!/usr/bin/bash

_test_array_contains_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_contains.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_contains_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local -i ret_code
    local -a array=('1 2' '3 4' 5 6)
    array_contains array '1 2' '3 4'
    ret_code=$?
    ((ret_code)) && {
        echo "${FUNCNAME[0]} test fail."
    } || {
        echo "${FUNCNAME[0]} test pass."
    }

    return $ret_code
}

test_case1
exit $?

