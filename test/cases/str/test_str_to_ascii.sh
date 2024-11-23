#!/usr/bin/bash

_test_str_to_ascii_old_dir="$PWD"
root_dir="${_test_str_to_ascii_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_to_ascii.sh || return 1
. ./cntr/cntr_map.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_to_asci_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    local str=COMMON
    local str_after=$(echo -n "$str" | str_to_ascii)
    
    if [[ "$str_after" == '43 4f 4d 4d 4f 4e' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local str=COMMON
    str_to_ascii str
    if [[ "$str" == '43 4f 4d 4d 4f 4e' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case3 ()
{
    local array=(COMMON dkgjege '232!*()' 'hhgagee!')
    cntr_map array str_to_ascii
    local array_after=([0]="43 4f 4d 4d 4f 4e" [1]="64 6b 67 6a 65 67 65" [2]="32 33 32 21 2a 28 29" [3]="68 68 67 61 67 65 65 21")
    if assert_array 'a' array array_after ; then
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

