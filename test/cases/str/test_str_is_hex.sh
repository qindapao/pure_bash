#!/usr/bin/bash

_test_str_is_hex_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_is_hex.sh || return 1
. ./cntr/cntr_grep.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_is_hex_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    local ret=''
    local str1='-000234'
    local str2='-0x00a34'
    local str3='+0X00234'
    local str4='-234'
    local str5='234'
    local str6='0x2abf34'
    local str7='0xabcl'

    str_is_hex "$str1" ; ret="$?$ret"
    str_is_hex "$str2" ; ret="$?$ret"
    str_is_hex "$str3" ; ret="$?$ret"
    str_is_hex "$str4" ; ret="$?$ret"
    str_is_hex "$str5" ; ret="$?$ret"
    str_is_hex "$str6" ; ret="$?$ret"
    str_is_hex "$str7" ; ret="$?$ret"

    if [[ "$ret" == '1011001' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

}

test_case2 ()
{
    local -a array=(-000234 -0x00a34 +0X00234 -234 234 0x2abf34 0xabcl '&*')
    local -a array_after=(-0x00a34 +0X00234 0x2abf34)
    cntr_grep array str_is_hex
    if assert_array 'a' array array_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case2

