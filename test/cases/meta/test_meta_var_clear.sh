#!/usr/bin/bash

_test_meta_var_clear_old_dir="$PWD"
root_dir="${_test_meta_var_clear_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_meta_var_clear_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local a='xxoo'
    local -i b=100
    local -a xy=(1 2 3)
    local -A xk=([123]=1 [456]=56)
    meta_var_clear a b xy xk
    if [[ -z "$a" ]] && [[ "$b" == '0' ]] && assert_array a xy PURE_BASH_NULL_ARRAY &&
        assert_array A xk PURE_BASH_NULL_DICT ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

