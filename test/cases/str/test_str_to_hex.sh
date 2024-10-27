#!/usr/bin/bash

_test_str_to_hex_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_to_hex.sh || return 1
. ./cntr/cntr_map.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_to_hex_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local str1='000567'
    local str1_after='0x237'

    str_to_hex str1

    if [[ "$str1" == "$str1_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local -a array=(000567 000785)
    local -a array_after=(0x237 0x311)
    cntr_map array str_to_hex

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
    local str=$(printf "%s" "000785" | str_to_hex)

    if [[ "$str" == '0x311' ]] ; then
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
geg']='000890' [my]='876' [my2]='0x987')
    local -A dict_after=(['xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)
geg']='0x37a' [my]='0x36c' [my2]='0x987')
    cntr_map dict str_to_hex
    if assert_array 'A' dict dict_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case3 &&
test_case2 &&
test_case4

