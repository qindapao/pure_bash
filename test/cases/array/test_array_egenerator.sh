#!/usr/bin/bash

_test_array_egenerator_old_dir="$PWD"
root_dir="${_test_array_egenerator_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_egenerator.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_egenerator_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

alias xx="date +'%Y_%m_%d_%H_%M_%S'"

test_case1 ()
{
    local -a a1=()
    array_egenerator a1 POWER 1 8
    
    local -a a2=(POWER1 POWER2 POWER3 POWER4 POWER5 POWER6 POWER7 POWER8)

    # 断言判断测试结果
    if assert_array 'a' a1 a2 ; then
        echo "${FUNCNAME[0]} pass"
        return 0
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
}

test_case1

