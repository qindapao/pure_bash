#!/usr/bin/bash

_test_for_old_dir="$PWD"
root_dir="${_test_for_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_for_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

alias xx="date +'%Y_%m_%d_%H_%M_%S'"

test_func ()
{
    local a
    for a ; do
        echo "a:$a"
    done
}

test_case1 ()
{
    local get_data=$(test_func '1 2' '3 4')

    if [[ "$get_data" == 'a:1 2
a:3 4' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

