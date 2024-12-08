#!/usr/bin/bash

_test_str_last_index_of_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_last_index_of.sh || return 1
. ./atom/atom_func_upstr.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_last_index_of_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    local a='是谁' b=我是谁不重要
    local ret_str
    atom_func_upstr ret_str \
        str_last_index_of "$b" "$a"
    if [[ "$ret_str" == '1' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local ret_str
    local a='xzyk17829ew829lexx1' b=829
    atom_func_upstr ret_str \
        str_last_index_of "$a" "$b"
    if [[ "$ret_str" == '11' ]] ; then
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
    atom_func_upstr ret_str \
        str_last_index_of "$b" "$a"
    if [[ "$ret_str" == '-1' ]] ; then
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
    atom_func_upstr ret_str \
        str_last_index_of "$a" "$b"
    if [[ "$ret_str" == '-1' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case5 ()
{
    local a='x1239940123邓恩给1235' b=123
    local ret_str
    atom_func_upstr ret_str \
        str_last_index_of "$a" "$b" 3
    if [[ "$ret_str" == '1' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

# a 空 b 空
test_case6 ()
{
    local a='' b=
    local ret_str
    atom_func_upstr ret_str \
        str_last_index_of "$a" "$b"
    if [[ "$ret_str" == '-1' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

# a 空 b 不空
test_case7 ()
{
    local a='' b=xx
    local ret_str
    atom_func_upstr ret_str \
        str_last_index_of "$a" "$b"
    if [[ "$ret_str" == '-1' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

# a不空 B空
test_case8 ()
{
    local a='xx' b=
    local ret_str
    atom_func_upstr ret_str \
        str_last_index_of "$a" "$b"
    if [[ "$ret_str" == '-1' ]] ; then
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
test_case4 &&
test_case5 &&
test_case6 &&
test_case7 &&
test_case8

