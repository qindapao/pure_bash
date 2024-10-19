#!/usr/bin/bash

_test_atom_upvar_old_dir="$PWD"
root_dir="${_test_atom_upvar_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./atom/atom_upvar.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_atom_upvar_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 () 
{
    local a=inner
    local -n a1="$1"
    a1=x
    declare -p a
    test_case2 "a1"
    declare -p a
}

test_case2 ()
{
    local "$1" && atom_upvar "$1" "xb"
}

a=out
test_case1 'a'
declare -p a

