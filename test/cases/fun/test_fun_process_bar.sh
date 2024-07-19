#!/usr/bin/bash

_test_fun_process_bar_old_dir="$PWD"
root_dir="${_test_fun_process_bar_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./fun/fun_process_bar.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_fun_process_bar_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    fun_process_bar 5
}

test_case2 ()
{
    fun_process_bar 10 "wait 10 s"
}

test_case1
test_case2

