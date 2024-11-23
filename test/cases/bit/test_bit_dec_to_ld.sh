#!/usr/bin/bash

_test_bit_dec_to_ld_old_dir="$PWD"
root_dir="${_test_bit_dec_to_ld_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./bit/bit_dec_to_ld.sh || return 1
. ./cntr/cntr_map.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_bit_dec_to_ld_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local xx=$(echo -n '888' | bit_dec_to_ld)
    local yy=$(echo -n '8888' | bit_dec_to_ld)
    local zz=$(echo -n '88888' | bit_dec_to_ld)
    if [[ $xx == '78 3' ]] &&
       [[ $yy == 'b8 22' ]] &&
       [[ $zz == '38 5b 1' ]] ; then
       echo "${FUNCNAME[0]} test pass" 
       return 0
    else
       echo "${FUNCNAME[0]} test fail" 
       return 1
    fi
}

test_case2 ()
{  
    local xx=888 yy=8888 zz=88888
    bit_dec_to_ld xx
    bit_dec_to_ld yy
    bit_dec_to_ld zz
    if [[ $xx == '78 3' ]] &&
       [[ $yy == 'b8 22' ]] &&
       [[ $zz == '38 5b 1' ]] ; then
       echo "${FUNCNAME[0]} test pass" 
       return 0
    else
       echo "${FUNCNAME[0]} test fail" 
       return 1
    fi
}

test_case3 ()
{
    local array=(888 8888 88888)
    cntr_map array bit_dec_to_ld 
    local -a array_after=('78 3' 'b8 22' '38 5b 1')
    if assert_array 'a' array array_after ; then
       echo "${FUNCNAME[0]} test pass" 
       return 0
    else
       echo "${FUNCNAME[0]} test fail" 
       return 1
    fi
}

test_case1 &&
test_case2 &&
test_case3

