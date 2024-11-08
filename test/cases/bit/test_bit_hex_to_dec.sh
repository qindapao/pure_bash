#!/usr/bin/bash

_test_bit_hex_to_dec_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./bit/bit_hex_to_dec.sh || return 1
. ./cntr/cntr_map.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_bit_hex_to_dec_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local str1='0x237'
    local str2='237'
    local str1_after='567'

    bit_hex_to_dec str1
    bit_hex_to_dec str2

    if [[ "$str1" == "$str1_after" ]] &&
       [[ "$str2" == "$str1_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local -a array=(0x237 0x311)
    local -a array_after=(567 785)
    cntr_map array bit_hex_to_dec

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
    local str=$(printf "%s" "0x311" | bit_hex_to_dec)

    if [[ "$str" == '785' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case4 ()
{
    local -A dict=(['xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)
geg']='0x37a' [my]='36C' [my2]='0x987')
    local -A dict_after=(['xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)
geg']='890' [my]='876' [my2]='2439')
    cntr_map dict bit_hex_to_dec
    if assert_array 'A' dict dict_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case2 &&
test_case3 &&
test_case4

