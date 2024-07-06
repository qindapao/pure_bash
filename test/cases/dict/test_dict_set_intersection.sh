#!/usr/bin/bash

_test_dict_set_intersection_old_dir="$PWD"
root_dir="${_test_dict_set_intersection_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./dict/dict_set_intersection.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_dict_set_intersection_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local -A dict1=(['12
34']="mx" [dfe]=2 [03]=1 [dfx]=1)
    local -A dict2=(['12
34']=1 [dfe1]=2 [03]=1 [dfx]=1 [dfxp]=1)
    local -A dict_ret=()
    eval "dict_ret=$(dict_set_intersection 'dict1' 'dict2')"
    local -A dest_dict=(
['12
34']=1 [03]=1 [dfx]=1
)

    # 断言判断测试结果
    if assert_array 'A' dict_ret dest_dict ; then
        # :TODO: 打印测试用例的函数名字
        echo "${FUNCNAME[0]} test pass"
    else
        echo "${FUNCNAME[0]} test fail"
    fi
}

test_case1


