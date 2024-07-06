#!/usr/bin/bash

_test_array_einsert_at_old_dir="$PWD"
root_dir="${_test_array_einsert_at_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_einsert_at.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_einsert_at_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local a1=(5 4 3)
    array_einsert_at a1 1 "xx oo" "11 22"
    local a2=(5 'xx oo' '11 22' 4 3)

    declare -p a1

    # 断言判断测试结果
    if assert_array a a1 a2 ; then
        echo "${FUNCNAME[0]} test pass"
    else
        echo "${FUNCNAME[0]} test fail"
    fi
}

test_case1

