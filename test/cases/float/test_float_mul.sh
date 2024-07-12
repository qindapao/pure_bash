#!/usr/bin/bash

_test_float_mul_old_dir="$PWD"
root_dir="${_test_float_mul_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./float/float_mul.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_float_mul_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    time float_mul '' '-10.1' -10.2 -5
    declare -p _FLOAT_MUL
}

test_case1

