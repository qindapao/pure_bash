#!/usr/bin/bash

_test_str_common_prefix_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_common_prefix.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_common_prefix_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    local a='xzy' b=xzyxx1
    local ret_str
    str_common_prefix "$a" "$b"
    if [[ "$ret_str" == 'xzy' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local a='xzyk17829' b=xzyk1xx1
    local ret_str
    str_common_prefix "$a" "$b"
    if [[ "$ret_str" == 'xzyk1' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case3 ()
{
    local a='' b=xzyk1xx1
    local ret_str
    str_common_prefix "$a" "$b"
    if [[ "$ret_str" == '' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case4 ()
{
    local a='12399405' b=xzyk1xx1
    local ret_str
    str_common_prefix "$a" "$b"
    if [[ "$ret_str" == '' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case2 &&
test_case3 &&
test_case4

