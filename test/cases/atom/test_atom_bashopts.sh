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

# set -xv

test_case1 ()
{
    local bashopt_recover1=''
    local bashopt_recover2=''

    local assert_flag=
    assert_flag=$(shopt | grep 'sourcepath' | awk '{print $2}')
    case "$assert_flag" in
    on) assert_flag='-s' ;;
    off) assert_flag='-u' ;;
    esac

    atom_bashopts 'sourcepath' bashopt_recover1 '-s'
    shopt "$bashopt_recover1" sourcepath

    atom_bashopts 'sourcepath' bashopt_recover2 '-u'
    shopt "$bashopt_recover2" sourcepath

    if [[ "$bashopt_recover1" == "$assert_flag" ]] &&
       [[ "$bashopt_recover2" == "$assert_flag" ]] ; then
        echo "${FUNCNAME[0]} pass"
        return 0
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
}

test_case2 ()
{
    local bashopt_recover1=''
    local bashopt_recover2=''

    local assert_flag=
    assert_flag=$(shopt | grep 'nocasematch' | awk '{print $2}')
    case "$assert_flag" in
    on) assert_flag='-s' ;;
    off) assert_flag='-u' ;;
    esac

    atom_bashopts 'nocasematch' bashopt_recover1 '-s'
    shopt "$bashopt_recover1" nocasematch

    atom_bashopts 'nocasematch' bashopt_recover2 '-u'
    shopt "$bashopt_recover2" nocasematch

    if [[ "$bashopt_recover1" == "$assert_flag" ]] &&
       [[ "$bashopt_recover2" == "$assert_flag" ]] ; then
        echo "${FUNCNAME[0]} pass"
        return 0
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
}

# 这样一个用例失败后面的就不会执行
test_case1 &&
test_case2

