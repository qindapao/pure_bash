#!/usr/bin/bash

_test_str_is_int_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_is_int.sh || return 1
. ./cntr/cntr_grep.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_is_int_old_dir"

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
    local str8='-0982'
    local str9='+ge11'
    local str10='908'

    str_is_int "$str1" ; ret="$?$ret"
    str_is_int "$str2" ; ret="$?$ret"
    str_is_int "$str3" ; ret="$?$ret"
    str_is_int "$str4" ; ret="$?$ret"
    str_is_int "$str5" ; ret="$?$ret"
    str_is_int "$str6" ; ret="$?$ret"
    str_is_int "$str7" ; ret="$?$ret"
    str_is_int "$str8" ; ret="$?$ret"
    str_is_int "$str9" ; ret="$?$ret"
    str_is_int "$str10" ; ret="$?$ret"

    if [[ "$ret" == '0101000000' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

}

test_case2 ()
{
    local -a array=(-000234 -0x00a34 +0X00234 -234 234 0x2abf34 0xabcl '&*' 0982 +ge11 908)
    local -a array_after=(-000234 -0x00a34 +0X00234 -234 234 0x2abf34 0982 908)
    cntr_grep array str_is_int
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

