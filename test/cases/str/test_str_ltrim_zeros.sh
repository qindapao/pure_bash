#!/usr/bin/bash

_test_str_ltrim_zeros_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_ltrim_zeros.sh || return 1
. ./cntr/cntr_map.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_ltrim_zeros_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local str1=00023434xxx
    local str2=xgeg0021
    local str3=00000
    local str4=xxxge000
    local str5=0ierr38383

    str_ltrim_zeros str1
    str_ltrim_zeros str2
    str_ltrim_zeros str3
    str_ltrim_zeros str4
    str_ltrim_zeros str5

    if [[ "$str1" == '23434xxx' ]] &&
        [[ "$str2" == 'xgeg0021' ]] &&
        [[ "$str3" == '0' ]] &&
        [[ "$str4" == 'xxxge000' ]] &&
        [[ "$str5" == 'ierr38383' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local -a array=(00023434xxx xgeg0021 00000 xxxge000 0ierr38383)
    local -a array_after=(23434xxx xgeg0021 0 xxxge000 ierr38383)
    cntr_map array str_ltrim_zeros
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
    local str=$(echo "000000/root/testPlat/xx y/1.txt" | str_ltrim_zeros)
    if [[ "$str" == '/root/testPlat/xx y/1.txt' ]] ; then
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

