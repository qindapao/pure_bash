#!/usr/bin/bash

_test_set_union_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./set/set_union.sh || return 1
. ./atom/atom_func_reverse_params.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_set_union_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    # 注意下默认集合的每个元素都需要以x开头
    local -A dict1=(['x12
34']=1 [xdfe]=1 [x03]=1 [xdfx]=1)
    local -A dict2=(['x12
34']=1 [xdfe1]=1 [x03]=1 [xdfx]=1 [xdfxp]=1)
    local -A dict3=(['x56 gege geg ( : ) !
34']=1 [x1]=1 ['x2 3']=1 ['x 4 5']=1 [x6]=1)
    local -A dict_ret=()
    set_union 'dict_ret' 'dict1' 'dict2' 'dict3'


    local -A dest_dict=(
['x12
34']=1 [x03]=1 [xdfx]=1 [x03]=1 [xdfe1]=1 [xdfxp]=1 [xdfe]=1 [x1]=1 ['x2 3']=1
['x 4 5']=1 [x6]=1 ['x56 gege geg ( : ) !
34']=1
)
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

test_case2 ()
{
    atom_func_reverse_params
    if [[ "${1}" == 1 ]] \
        && [[ "${2}" == 2 ]] \
        && [[ "${3}" == 3 ]] \
        && [[ "${4}" == 4 ]] \
        && [[ "${5}" == 5 ]] \
        && [[ "${6}" == 6 ]] \
        && [[ "${7}" == ' 7 7' ]] \
        && [[ "${8}" == '8 8' ]] \
        && [[ "${9}" == '9 9' ]] \
        && [[ "${10}" == '10 10' ]] \
        && [[ "${11}" == '11 11' ]] ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi

    return 0
}

ret_str=''

test_case2 '11 11' '10 10' '9 9' '8 8' ' 7 7' 6 5 4 3 2 1
ret_str+="$?|"
test_case1
ret_str+="$?"

! ((ret_str))

