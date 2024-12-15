#!/usr/bin/bash

_test_test_dict_by_kv_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./dict/dict_by_kv.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_test_dict_by_kv_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv
#
# bash4.4上这里有差异
# Storage:~/qinqing/pure_bash/test/cases/dict # declare -A dict
# Storage:~/qinqing/pure_bash/test/cases/dict # declare -p dict
# declare -A dict
# Storage:~/qinqing/pure_bash/test/cases/dict # echo ${dict@a}

# Storage:~/qinqing/pure_bash/test/cases/dict # 
test_case1 ()
{
    local a=('1 2' ' 3 4' a b c d)
    local -A b_after=(["1 2"]=" 3 4" [c]="d" [a]="b" )
    local -A b=()
    dict_by_kv b a
    if assert_array 'A' b b_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

