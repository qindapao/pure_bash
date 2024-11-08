#!/usr/bin/bash

_test_bit_num_to_hex_old_dir="$PWD"
root_dir="${_test_bit_num_to_hex_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./bit/bit_num_to_hex.sh || return 1
. ./cntr/cntr_map.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_bit_num_to_hex_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local num_str1=0b11001 num_str1_after=0x19
    local num_str2=0x47575 num_str2_after=0x47575
    local num_str3=0X8746  num_str3_after=0x8746
    local num_str4=4256    num_str4_after=0x10a0
    local num_str5=0009834 num_str5_after=0x266a
    local num_str6=0b1101  num_str6_after=0xd
    bit_num_to_hex "num_str1"
    bit_num_to_hex "num_str2"
    bit_num_to_hex "num_str3"
    bit_num_to_hex "num_str4"
    bit_num_to_hex "num_str5"
    bit_num_to_hex "num_str6"

    if [[ "$num_str1" == "$num_str1_after" ]] &&
        [[ "$num_str2" == "$num_str2_after" ]] &&
        [[ "$num_str3" == "$num_str3_after" ]] &&
        [[ "$num_str4" == "$num_str4_after" ]] &&
        [[ "$num_str5" == "$num_str5_after" ]] &&
        [[ "$num_str6" == "$num_str6_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local num_str1=0b11001 num_str1_after=0x19
    local num_str2=0x47575 num_str2_after=0x47575
    local num_str3=0X8746  num_str3_after=0x8746
    local num_str4=4256    num_str4_after=0x10a0
    local num_str5=0009834 num_str5_after=0x266a
    local num_str6=0b1101  num_str6_after=0xd
    bit_num_to_hex "num_str1"
    bit_num_to_hex "num_str2"
    bit_num_to_hex "num_str3"
    bit_num_to_hex "num_str4"
    bit_num_to_hex "num_str5"
    bit_num_to_hex "num_str6"

    if [[ "$(echo -n "$num_str1" | bit_num_to_hex)" == "$num_str1_after" ]] &&
       [[ "$(echo -n "$num_str2" | bit_num_to_hex)" == "$num_str2_after" ]] &&
       [[ "$(echo -n "$num_str3" | bit_num_to_hex)" == "$num_str3_after" ]] &&
       [[ "$(echo -n "$num_str4" | bit_num_to_hex)" == "$num_str4_after" ]] &&
       [[ "$(echo -n "$num_str5" | bit_num_to_hex)" == "$num_str5_after" ]] &&
       [[ "$(echo -n "$num_str6" | bit_num_to_hex)" == "$num_str6_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case3 ()
{
    local -a num_arr=(0b11001 0x47575 0X8746 4256 0009834 0b1101)
    local -a num_arr_after=(0x19 0x47575 0x8746 0x10a0 0x266a 0xd)
    cntr_map num_arr bit_num_to_hex
    
    if assert_array a num_arr num_arr_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test pass."
        return 1
    fi
}


test_case1 &&
test_case2 &&
test_case3

