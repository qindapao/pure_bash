#!/usr/bin/bash

_test_atom_func_reverse_params_old_dir="$PWD"
root_dir="${_test_atom_func_reverse_params_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./atom/atom_func_reverse_params.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_atom_func_reverse_params_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 () 
{
    atom_func_reverse_params
    [[ "$1" == '5 z' ]] &&
    [[ "$2" == '4 k' ]] &&
    [[ "$3" == '3 z' ]] &&
    [[ "$4" == '2 y' ]] &&
    [[ "$5" == '1 x' ]] &&
    {
        echo "${FUNCNAME[0]} test pass."
        return 0
    }
    echo "${FUNCNAME[0]} test fail."
    return 1
}
test_case1 '1 x' '2 y' '3 z' '4 k' '5 z'

