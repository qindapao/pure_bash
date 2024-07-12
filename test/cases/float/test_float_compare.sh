#!/usr/bin/bash

_test_float_compare_old_dir="$PWD"
root_dir="${_test_float_compare_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./float/float_compare.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_float_compare_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local a=1.1
    local b=1.1

    float_compare "$a" "$b"
    echo "\$?: $?"
}

test_case2 ()
{
    local a=1.2
    local b=1.1

    float_compare "$a" "$b"
    echo "\$?: $?"
}

test_case3 ()
{
    local a=1.0
    local b=1.1

    float_compare "$a" "$b"
    echo "\$?: $?"
}

test_case1
test_case2
test_case3

