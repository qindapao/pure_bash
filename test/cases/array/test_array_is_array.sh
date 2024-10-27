#!/usr/bin/bash

_test_array_is_array_old_dir="$PWD"
root_dir="${_test_array_is_array_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_is_array.sh || return 1
. ./bit/bit_set.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_is_array_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local a1=(5)
    local -a a2
    local -A dict1
    local -A dict2
    local str1
    local str2=''
    local -i ret=0
    array_is_array a1 ; bit_set ret "0" "$?"
    array_is_array a2 ; bit_set ret "1" "$?"
    array_is_array dict1 ; bit_set ret "2" "$?"
    array_is_array dict2 ; bit_set ret "3" "$?"
    array_is_array str1 ; bit_set ret "4" "$?"
    array_is_array str2 ; bit_set ret "5" "$?"
    if ((ret==0x3c)) ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

