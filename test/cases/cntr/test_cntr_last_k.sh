#!/usr/bin/bash

_test_cntr_last_k_old_dir="$PWD"
root_dir="${_test_cntr_last_k_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./cntr/cntr_last_k.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_cntr_last_k_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

filter_func_need_value ()
{
    [[ "$1" == '2' ]]
}

test_case1 ()
{
    local array=(11 12 3 2 2 2 5 6 7)
    local last_index
    cntr_last_k array filter_func_need_value last_index
    if [[ "$last_index" == 5 ]] && [[ $? == 0 ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local array=(11 12 3 x x x 5 6 7)
    local last_index
    cntr_last_k array filter_func_need_value last_index
    if (($?)) ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case3 ()
{
    local array=()
    local last_index
    cntr_last_k array filter_func_need_value last_index
    if (($?)) ; then
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

exit $ret

