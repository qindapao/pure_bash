#!/usr/bin/bash

_test_remote_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./remote/remote_cmd2r.sh || return 1
. ./remote/remote_cp_l2r.sh || return 1
. ./remote/remote_cp_r2l.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_remote_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    echo "${FUNCNAME[0]} is disabled."
}

test_case1

