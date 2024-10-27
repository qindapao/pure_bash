#!/usr/bin/bash

_test_cntr_copy_old_dir="$PWD"
root_dir="${_test_cntr_copy_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./cntr/cntr_copy.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_cntr_copy_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

alias xx="date +'%Y_%m_%d_%H_%M_%S'"

test_case1 ()
{
    local -a a1=("10:7:5" "8:9:4" "11:2:6" "4:1:7")
    local -a a2=()

    cntr_copy a2 a1

    # 断言判断测试结果
    if assert_array 'a' a1 a2 ; then
        # :TODO: 打印测试用例的函数名字
        echo "${FUNCNAME[0]} pass"
        return 0
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
}

test_case2 ()
{
    local -A a1=([abc]=1 [def]=1)
    local -A a2=()

    cntr_copy a2 a1
    
    if assert_array 'A' a1 a2 ; then
        echo "${FUNCNAME[0]} pass"
        return 0
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
}

test_case1 &&
test_case2

