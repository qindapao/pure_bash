#!/usr/bin/bash

_test_date_print_elapsed_time_old_dir="$PWD"
root_dir="${_test_date_print_elapsed_time_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./date/date_print_elapsed_time.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_date_print_elapsed_time_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local start=$SECONDS
    sleep 2
    local log_time=$(date_print_elapsed_time)
    local log_time_s=$(echo "$log_time" | awk -F ":" '{print $NF}' | awk -F "." '{print $1}')
    log_time_s=$((10#$log_time_s))

    if ((log_time_s-start>=2)) ; then
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

