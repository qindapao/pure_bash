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
    local ret=''
    local str='echo hello world'
    local -a b=(echo hello world) c=('(' '(')

    str_to_array a "$str"
    assert_array a 'a' 'b' ; ret="$?$ret"

    str='( ('
    str_to_array a "$str" ' '

    assert_array 'a' a c ; ret="$?$ret"

    if [[ "$ret" == '00' ]] ; then
        echo "${FUNCNAME[0]} pass"
        return 0
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
}

test_case1

