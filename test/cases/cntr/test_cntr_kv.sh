#!/usr/bin/bash

_test_cntr_kv_old_dir="$PWD"
root_dir="${_test_cntr_kv_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./cntr/cntr_kv.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_cntr_kv_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local array=(1 'x o' '2 3' '*&')
    local array_kv=()
    cntr_kv array_kv array
    local array_kv_after=(0 1 1 'x o' 2 '2 3' 3 '*&')
    if assert_array 'a' array_kv array_kv_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local -A dict=([xo]=1 [' y x']='2 3' [4]=xo)
    local -a dict_kv
    cntr_kv dict_kv dict
    local -a dict_kv_after1=(xo 1 ' y x' '2 3' 4 xo)
    local -a dict_kv_after2=(xo 1 4 xo ' y x' '2 3')
    local -a dict_kv_after3=(' y x' '2 3' xo 1 4 xo)
    local -a dict_kv_after4=(4 xo xo 1 ' y x' '2 3')
    local -a dict_kv_after5=(4 xo ' y x' '2 3' xo 1 )
    local -a dict_kv_after6=(' y x' '2 3' 4 xo xo 1 )

    if assert_array 'a' dict_kv dict_kv_after1 ||
       assert_array 'a' dict_kv dict_kv_after2 ||
       assert_array 'a' dict_kv dict_kv_after3 ||
       assert_array 'a' dict_kv dict_kv_after4 ||
       assert_array 'a' dict_kv dict_kv_after5 ||
       assert_array 'a' dict_kv dict_kv_after6 ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

ret=0
test_case1
((ret|=$?))
test_case2
((ret|=$?))

exit $ret

