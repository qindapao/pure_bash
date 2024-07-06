#!/usr/bin/bash

_test_array_eshift_old_dir="$PWD"
root_dir="${_test_array_eshift_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_eshift.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_eshift_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local a1=(5 4 3)
    local ret
    array_eshift a1 ret
    local a2=(4 3)
    local -i bool1 bool2
    assert_array a a1 a2 ; bool1=$?
    [[ '5' == "$ret" ]] ; bool2=$?

    declare -p a1
    declare -p ret

    # 断言判断测试结果
    if [[ "$bool1" == '0' ]] && [[ "$bool2" == '0' ]] ; then
        echo "${FUNCNAME[0]} test pass"
    else
        echo "${FUNCNAME[0]} test fail"
    fi
}

test_case1

