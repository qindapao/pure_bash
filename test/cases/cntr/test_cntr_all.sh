#!/usr/bin/bash

_test_cntr_all_old_dir="$PWD"
root_dir="${_test_cntr_all_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./cntr/cntr_all.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_cntr_all_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

filter_func_need_value ()
{
    [[ "$1" == '2' ]]
}

test_case1 ()
{
    local -A dict
    dict['gggeg]']=2
    dict['xx 2']=2
    dict[xxoo]=2
    dict['xxo()o
    ]']=2
    if cntr_all dict filter_func_need_value ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local -a array=(2 2 2 2 2 2 2)
    if cntr_all array filter_func_need_value ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case3 ()
{
    local -a array=('4 5' '4 5' '4 5')
    if cntr_all array '[[ "${1}" == "4 5" ]]' ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case4 ()
{
    local -a array=()
    if cntr_all array '[[ "${1}" == "4 5" ]]' ; then
        # 空数组返回真
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

ret=0
test_case1
((ret|=$?))
test_case2
((ret|=$?))
test_case3
((ret|=$?))
test_case4
((ret|=$?))

exit $ret

