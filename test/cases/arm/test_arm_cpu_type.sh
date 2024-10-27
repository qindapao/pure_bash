#!/usr/bin/bash

_test_arm_cpu_type_all_old_dir="$PWD"
root_dir="${_test_arm_cpu_type_all_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_arm_cpu_type_all_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="


# 验证eval和函数别名的结合使用

test_case1 () 
{
    :
}

test_case1

