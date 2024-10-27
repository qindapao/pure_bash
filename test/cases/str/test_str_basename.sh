#!/usr/bin/bash

_test_str_basename_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_basename.sh || return 1
. ./cntr/cntr_map.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_basename_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    local str1='/root/xx/yy/tnt.txt'
    local str1_after='tnt'

    str_basename str1
    if [[ "$str1" == "$str1_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local -a array=('/root/xx/y  y/tnt.txt' '/gege/g  ege/kk/y y.txt' '/gge/geg/yy.ini')
    local -a array_after=('tnt' 'y y' 'yy')
    cntr_map array str_basename
    if assert_array 'a' array array_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case3 ()
{
    local str1=$(echo '/root/xx/yy/tnt.txt' | str_basename)
    local str1_after='tnt'

    if [[ "$str1" == "$str1_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case2 &&
test_case3

