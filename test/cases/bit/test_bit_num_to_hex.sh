#!/usr/bin/bash

_test_bit_num_to_hex_old_dir="$PWD"
root_dir="${_test_bit_num_to_hex_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./bit/bit_num_to_hex.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_bit_num_to_hex_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local num_str1=0b11001 num_str1_after=0x19
    local num_str2=0x47575 num_str2_after=0x47575
    local num_str3=0X8746  num_str3_after=0x8746
    local num_str4=4256    num_str4_after=0x10a0
    local num_str5=0009834 num_str5_after=0x266a
    local num_str1_cal=$(bit_num_to_hex "$num_str1")
    local num_str2_cal=$(bit_num_to_hex "$num_str2")
    local num_str3_cal=$(bit_num_to_hex "$num_str3")
    local num_str4_cal=$(bit_num_to_hex "$num_str4")
    local num_str5_cal=$(bit_num_to_hex "$num_str5")

    if [[ "$num_str1_cal" == "$num_str1_after" ]] &&
        [[ "$num_str2_cal" == "$num_str2_after" ]] &&
        [[ "$num_str3_cal" == "$num_str3_after" ]] &&
        [[ "$num_str4_cal" == "$num_str4_after" ]] &&
        [[ "$num_str5_cal" == "$num_str5_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

