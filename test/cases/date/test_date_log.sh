#!/usr/bin/bash

_test_date_log_old_dir="$PWD"
root_dir="${_test_date_log_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_date_log_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local log_time=$(date_log)

    if [[ "$log_time" =~ ^[0-9]{4}(_[0-9]{2}){5}$ ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

ret=0
test_case1
((ret|=$?))

exit $ret

