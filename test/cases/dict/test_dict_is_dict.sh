#!/usr/bin/bash

_test_dict_is_dict_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./dict/dict_is_dict.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_dict_is_dict_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local -a array1
    local -a array2=()
    local -a array3=(1 2)
    local -A dict1
    local -A dict2=()
    local -A dict3=([xx]=1)
    local str1
    local str2="xx"
    local -i num1
    local -i num2=10

    local spec='1111000111'
    local ret=""

    dict_is_dict array1 ; ret="$?$ret"
    dict_is_dict array2 ; ret="$?$ret"
    dict_is_dict array3 ; ret="$?$ret"
    dict_is_dict dict1 ; ret="$?$ret"
    dict_is_dict dict2 ; ret="$?$ret"
    dict_is_dict dict3 ; ret="$?$ret"
    dict_is_dict str1 ; ret="$?$ret"
    dict_is_dict str2 ; ret="$?$ret"
    dict_is_dict num1 ; ret="$?$ret"
    dict_is_dict num2 ; ret="$?$ret"
    if [[ "$ret" == "$spec" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

