#!/usr/bin/bash

_test_dict_is_key_contain_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./dict/dict_is_key_contain.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_dict_is_key_contain_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local -A dict=(['x 1 2 3']=1 ['x 5 6 7']='xx')
    local -A dict1=([ute]=x4 [yui]=132)
    
    local ret=''
    local spec="10"
    dict_is_key_contain dict '1 2 3' ; ret="$?$ret"
    dict_is_key_contain dict1 '1 2 3' ; ret="$?$ret"
    if [[ "$ret" == "$spec" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 0
    fi
}

test_case1

