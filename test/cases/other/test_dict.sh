#!/usr/bin/bash

_test_dict_old_dir="$PWD"
root_dir="${_test_dict_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./dict/dict_extend.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_dict_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

alias xx="date +'%Y_%m_%d_%H_%M_%S'"

test_case1 ()
{
    local -A m=()
    local -A xx=()
    
    xx['zy
    xk
    122']='geg
    gege'

    xx['45g 
    geg
    ']='gge
    gege
    123'
    declare -p xx
    dict_extend m xx
    declare -p m
}

test_case1

