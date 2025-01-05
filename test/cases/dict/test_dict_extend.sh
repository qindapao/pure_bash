#!/usr/bin/bash

_test_dict_extend_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./dict/dict_extend.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_dict_extend_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local -A dict1=([xo]=1 [' 1 5']='6 7')
    local -A dict2=([qq]='gge
ggge
gge' [' 1
5']='6 7' [gge]=2)
    
    dict_extend dict1 dict2
    local -A dict_after=([xo]=1 [' 1 5']='6 7' [qq]='gge
ggge
gge' [' 1
5']='6 7' [gge]=2)
    if assert_array 'A' dict1 dict_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

