#!/usr/bin/bash

_test_set_diff_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./set/set_diff.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_set_diff_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local ret_str=''
    # 注意下默认集合的每个元素都需要以x开头
    local -A dict1=([x1]=1 [x2]=1 [x3]=1 [x4]=1)
    local -A dict2=([x3]=1 [x2]=1)
    local -A dict3=([x2]=1 [x4]=1)
    local -A dict_spec_diff2=([x1]=1 [x4]=1)
    local -A dict_spec_diff3=([x1]=1 [x3]=1)
    local -A dict_diff2 dict_diff3

    set_diff 'dict1' 'dict2' 'dict_diff2'
    set_diff 'dict1' 'dict3' 'dict_diff3'

    assert_array A 'dict_diff2' 'dict_spec_diff2'
    ret_str+="$?|"
    assert_array A 'dict_diff3' 'dict_spec_diff3'
    ret_str+="$?"

    if ((ret_str)) ; then
        echo "${FUNCNAME[0]} fail"
        return 1
    else
        echo "${FUNCNAME[0]} pass"
    fi
    return 0
}

test_case1

