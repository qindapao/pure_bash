#!/usr/bin/bash

_test_cntr_grep_old_dir="$PWD"
root_dir="${_test_cntr_grep_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./cntr/cntr_grep.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_cntr_grep_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

filter_func_need_value ()
{
    [[ "$1" == '2' ]]
}

filter_func_need_value2 ()
{
    [[ "$3" == '2' ]]
}

alias my_xx_ali='filter_func_need_value2 "1 2 " "3 4 a"'


test_case1 ()
{
    local -A dict
    local -A dict_after=(['xx 2']=2)
    dict['gggeg]']=1
    dict['xx 2']=2
    dict[xxoo]=4
    dict['xxo()o
    ]']=x
    cntr_grep dict filter_func_need_value
    if assert_array 'A' dict dict_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local -a array=(1 2 3 4 x x y)
    local -a array_after=(2)
    cntr_grep array filter_func_need_value
    if assert_array 'a' array array_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case3 ()
{
    local -a array=(1 2 3 4 5 5 6 ' 4 5' '5' ' 4 5')
    local -a array_after=(' 4 5' ' 4 5')
    cntr_grep array '[[ "${1}" == " 4 5" ]]'
    if assert_array 'a' array array_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case4 ()
{
    local -a array=(1 2 3 4 x x y 2)
    local -a array_after=(2 2)
    cntr_grep array my_xx_ali
    if assert_array 'a' array array_after ; then
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

