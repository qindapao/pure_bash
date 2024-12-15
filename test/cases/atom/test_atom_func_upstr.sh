#!/usr/bin/bash

_test_atom_func_upstr_old_dir="$PWD"
root_dir="${_test_atom_func_upstr_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./atom/atom_func_upstr.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_atom_func_upstr_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_func ()
{
    REPLY='xx oo'
    echo "$1"
    echo "$2"
    shift 2
    echo "$*"
}

alias test_func_alias='test_func "x o" "1 2"'

test_case1 () 
{
    local ret_xx
    atom_func_upstr ret_xx \
        test_func 1 2 3 4 '5 6'
    if [[ "$ret_xx" == 'xx oo' ]] ; then
        echo "${FUNCNAME[0]} test pass."
    else
        echo "${FUNCNAME[0]} test fail."
    fi
}

test_case2 ()
{
    local ret_xx
    atom_func_upstr ret_xx \
        test_func_alias 1 2 3 4 '5 6'
    if [[ "$ret_xx" == 'xx oo' ]] ; then
        echo "${FUNCNAME[0]} test pass."
    else
        echo "${FUNCNAME[0]} test fail."
    fi

}

test_case1 &&
test_case2

