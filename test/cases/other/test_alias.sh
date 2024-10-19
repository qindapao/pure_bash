#!/usr/bin/bash

_test_alias_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./date/date_log.sh || return 1
. ./atom/atom_my.sh || return 1
. ./log/log_dbg.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_alias_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

alias test_x='echo "haha"'

test_func ()
{
    test_x
}

alias x1='test_func "0 1"'

test_case1 ()
{
    local ret1 ret2
    local -i ret_code=0

    ret1=$(x1)
    y=x1
    ret2=$(eval -- "$y")
    declare -p ret1 ret2
    if [[ "$ret1" == 'haha' && "$ret2" == 'haha' ]] ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        ret_code=1
    fi

    return $ret_code
}

test_case1

