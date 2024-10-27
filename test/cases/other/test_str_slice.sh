#!/usr/bin/bash

_test_str_slice_old_dir="$PWD"
root_dir="${_test_str_slice_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_slice_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="


test_case1 ()
{
    a="我是谁"
    if [[ "${a:0:1}" == '我' ]] &&
        [[ "${a:1:1}" == '是' ]] &&
        [[ "${a:2:1}" == '谁' ]] &&
        [[ "${a#?}" == '是谁' ]] &&
        [[ "${a#??}" == '谁' ]] &&
        [[ "${a#???}" == '' ]] ; then
           echo "${FUNCNAME[0]} test pass."
           return 0
       else
           echo "${FUNCNAME[0]} test fail."
           return 1
    fi
}

test_case1

