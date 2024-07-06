#!/usr/bin/bash

_test_unset_old_dir="$PWD"
root_dir="${_test_unset_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_copy.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_unset_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

alias xx="date +'%Y_%m_%d_%H_%M_%S'"

test_case1 ()
{
    local a=3
    test_case2
    declare -p a
}

test_case2 ()
{
    local a=2
    unset a
    declare -p a
}

a=2
test_case1
declare -p a

