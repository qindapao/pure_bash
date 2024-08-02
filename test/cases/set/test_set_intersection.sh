#!/usr/bin/bash

_test_set_intersection_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./set/set_intersection.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_set_intersection_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    # 注意下默认集合的每个元素都需要以x开头
    local -A dict1=(['x12
34']="mx" [xdfe]=2 [x03]=1 [xdfx]=1)
    local -A dict2=(['x12
34']=1 [xdfe1]=2 [x03]=1 [xdfx]=1 [xdfxp]=1)
    local -A dict_ret=()
    set_intersection 'dict_ret' 'dict1' 'dict2'
    local -A dest_dict=(
['x12
34']=1 [x03]=1 [xdfx]=1
)
    declare -p dict_ret dest_dict

    # 断言判断测试结果
    if assert_array 'A' dict_ret dest_dict ; then
        # :TODO: 打印测试用例的函数名字
        echo "${FUNCNAME[0]} test pass"
    else
        echo "${FUNCNAME[0]} test fail"
        return 1
    fi

    return 0
}

test_case1

