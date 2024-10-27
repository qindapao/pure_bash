#!/usr/bin/bash

_test_atom_is_varname_valid_old_dir="$PWD"
root_dir="${_test_atom_is_varname_valid_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./atom/atom_is_varname_valid.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_atom_is_varname_valid_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 () 
{
    local ret='0'
    local success_str='1010010'
    atom_is_varname_valid 'abc0'   
    ret=$?
    atom_is_varname_valid '0abc0'   
    ret="$?$ret"
    atom_is_varname_valid '_abc0'   
    ret="$?$ret"
    atom_is_varname_valid 'A__abc0'   
    ret="$?$ret"
    atom_is_varname_valid 'A*_abc0'   
    ret="$?$ret"
    atom_is_varname_valid 'A'   
    ret="$?$ret"
    atom_is_varname_valid '~'   
    ret="$?$ret"

    if [[ "$ret" == "$success_str" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail.ret:${ret};"
        return 1
    fi
}
test_case1

