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
    local ret=0
    local a=inner
    local -n a1="$1"
    a1=x
    if [[ "$a" != 'x' ]] ; then
        ret=1
    fi
    test_case2 "a1"
    if [[ "$a" != 'xb' ]] ; then
        ret=1
    fi
    if ((ret)) ; then
        echo "${FUNCNAME[0]} test fail."
    else
        echo "${FUNCNAME[0]} test pass."
    fi
    return $ret

}

test_case2 ()
{
    local "$1" && atom_upvar "$1" "xb"
}

a=out
test_case1 'a'

