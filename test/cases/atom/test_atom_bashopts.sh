#!/usr/bin/bash

_test_atom_bashopts_old_dir=$PWD
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./atom/atom_bashopts.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_atom_bashopts_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local bashopt_recover=''
    atom_bashopts 'sourcepath' bashopt_recover

    shopt -u sourcepath
    shopt | grep -w sourcepath


    shopt "$bashopt_recover" sourcepath

    if [[ "$bashopt_recover" == '-s' ]] ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
    fi
}

test_case2 ()
{
    local bashopt_recover
    atom_bashopts 'nocasematch' bashopt_recover

    shopt -s nocasematch
    shopt | grep -w nocasematch

    shopt "$bashopt_recover" nocasematch
    
    if [[ "$bashopt_recover" == '-u' ]] ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
    fi
}


shopt | grep sourcepath
test_case1
shopt | grep sourcepath

shopt | grep nocasematch
test_case2
shopt | grep nocasematch

