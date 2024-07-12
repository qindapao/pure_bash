#!/usr/bin/bash

_test_bit_reg_h8_old_dir="$PWD"
root_dir="${_test_bit_reg_h8_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./bit/bit_reg_h8.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_bit_reg_h8_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    xx=$(bit_reg_h8 0xaabb)
    if [[ $xx == 0xaa ]] ; then
       echo "${FUNCNAME[0]} test pass" 
    else
       echo "${FUNCNAME[0]} test fail" 
    fi
}

test_case1

