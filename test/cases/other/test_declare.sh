#!/usr/bin/bash

_test_declare_old_dir="$PWD"
root_dir="${_test_declare_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_declare_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="


test_case1 ()
{
    declare a=1
    declare -n b=a
    declare -p a
    declare -p b
    test_case2
}

test_case2 ()
{
    declare -p a
    declare -p b
}

test_case1
declare -p a
declare -p b

