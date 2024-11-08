#!/usr/bin/bash

_test_str_common_suffix_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_common_suffix.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_common_suffix_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    local a='xzy9081' b=xzyxxxzy9081
    local ret
    str_common_suffix "$a" "$b"
    if [[ "$ret" == 'xzy9081' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local a='xzyk17829ewlexx1' b=xzyk1xx1
    local ret
    str_common_suffix "$a" "$b"
    if [[ "$ret" == 'xx1' ]] ; then
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
    local ret
    str_common_suffix "$a" "$b"
    if [[ "$ret" == '' ]] ; then
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
    local ret
    str_common_suffix "$a" "$b"
    if [[ "$ret" == '' ]] ; then
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

