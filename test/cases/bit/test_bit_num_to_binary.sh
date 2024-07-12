#!/usr/bin/bash

_test_bit_bit_num_to_binary _old_dir="$PWD"
root_dir="${_test_bit_bit_num_to_binary%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./bit/bit_num_to_binary.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_bit_bit_num_to_binary"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local a=10
    local b=$(bit_num_to_binary "$a")
    if [[ "$b" = '1010' ]] ; then
        echo "${FUNCNAME[0]} test pass"
    else
        echo "${FUNCNAME[0]} test fail"
    fi
}

test_case2 ()
{
    local a=0b1010111
    local b=$(bit_num_to_binary "$a")
    if [[ "$b" = '1010111' ]] ; then
        echo "${FUNCNAME[0]} test pass"
    else
        echo "${FUNCNAME[0]} test fail"
    fi
}

test_case3 ()
{
    local a=0xaa
    local b=$(bit_num_to_binary "$a")
    if [[ "$b" = '10101010' ]] ; then
        echo "${FUNCNAME[0]} test pass"
    else
        echo "${FUNCNAME[0]} test fail"
    fi
}
test_case1
test_case2
test_case3

