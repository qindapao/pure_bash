#!/usr/bin/bash

_test_atom_identify_data_type_old_dir=$PWD
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./atom/atom_identify_data_type.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_atom_identify_data_type_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local a=(1 2 3 4)
    local -A b=([xx]=1)
    local -i i=0
    local xx
    local ret=0
    atom_identify_data_type a 'a'
    ((ret|=$?))
    atom_identify_data_type b 'A'
    ((ret|=$?))
    atom_identify_data_type i 'i'
    ((ret|=$?))
    atom_identify_data_type xx 's'
    ((ret|=$?))
    
    if ((ret)) ; then
        echo "${FUNCNAME[0]} test fail."
    else
        echo "${FUNCNAME[0]} test pass."
    fi

    return $ret
}

test_case1

