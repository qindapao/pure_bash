#!/usr/bin/bash

_test_indirect_ref_old_dir="$PWD"
root_dir="${_test_indirect_ref_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_indirect_ref_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="


test_case1 ()
{
    test_case2 "$1"
}

test_case2 ()
{
    test_case3 "${!1}"
}

test_case3 ()
{
    local m="$1"
    # 可以按照预期打印出来值
    declare -p m
}

declare -n a=b
declare -n b=c
declare -n c=d
d='112 33'
test_case1 'a'

