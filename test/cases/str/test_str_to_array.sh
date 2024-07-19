#!/usr/bin/bash

_test_str_to_array_old_dir="$PWD"
root_dir="${_test_str_to_array_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_to_array.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_to_array_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local str='echo hello world'
    local -a b=(echo hello world) c=('(' '(')

    str_to_array a "$str"
    if assert_array a 'a' 'b' ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
    fi
    str='( ('
    str_to_array a "$str" ' '
    if assert_array a 'a' 'c' ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
    fi
}

test_case1

