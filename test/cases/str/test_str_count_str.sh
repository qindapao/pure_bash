#!/usr/bin/bash

_test_str_count_str_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_count_str.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_count_str_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

set -vx
test_case1 ()
{
    local a='12345sabsabsaxs' b='sa'
    local cnt1 cnt2
    str_count_str "$a" "$b" cnt1
    cnt2=$(str_count_str "$a" "$b")
    if [[ "$cnt1" == '3' && "$cnt2" == '3' ]] ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
    return 0
}

test_case2 ()
{
    local a="中文情况情况情节" b='情况'
    local cnt1
    str_count_str "$a" "$b" cnt1
    if [[ "$cnt1" == '2' ]] ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
    return 0
}

test_case3 ()
{
    local a='abc' b=''
    local cnt1
    str_count_str "$a" "$b" cnt1
    if [[ "0" == "$cnt1" ]] ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
    return 0
}


ret_str=''

test_case1
ret_str+="$?|"
test_case2
ret_str+="$?|"
test_case3
ret_str+="$?"

! ((ret_str))

