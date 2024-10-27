#!/usr/bin/bash

_test_date_get_date_from_second_old_dir="$PWD"
root_dir="${_test_date_get_date_from_second_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./date/date_get_date_from_second.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_date_get_date_from_second_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local year=1990
    local seconds=100567
    local now_time
    local now_time_after='1990-01-02-03-56-07'
    now_time=$(date_get_date_from_second "$year" "$seconds")

    local year1=2019
    local seconds1=800567000
    local now_time_after1='2044-05-14-19-43-20'
    local now_time1
    now_time1=$(date_get_date_from_second "$year1" "$seconds1")

    if [[ "$now_time" == "$now_time_after" ]] &&
        [[ "$now_time1" == "$now_time_after1" ]] ; then
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

