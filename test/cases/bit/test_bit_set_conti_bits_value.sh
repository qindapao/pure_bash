#!/usr/bin/bash

_test_bit_set_conti_bits_value_old_dir="$PWD"
root_dir="${_test_bit_set_conti_bits_value_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./bit/bit_set_conti_bits_value.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_bit_set_conti_bits_value_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local a=0x34a
    local a_set=$(bit_set_conti_bits_value_s "$a" '7~0' '0b10101010')
    local a_set_after=0x3aa
    if ((a_set==a_set_after)) ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

