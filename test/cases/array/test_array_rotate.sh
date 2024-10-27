#!/usr/bin/bash

_test_array_rotate_old_dir="$PWD"
root_dir="${_test_array_rotate_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_rotate.sh || return 1
. ./bit/bit_set.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_rotate_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local -i ret=0
    local -a array=([100]=1 [103]=2 [107]=5 [110]='6 7' [134]=xo)
    array_rotate array 1
    local -a array_rotate_1=([100]=2 [103]=5 [107]='6 7' [110]=xo [134]=1)
    assert_array 'a' array array_rotate_1 ; bit_set ret 0 $? 
    local -a array=([100]=1 [103]=2 [107]=5 [110]='6 7' [134]=xo)
    array_rotate array 2
    local -a array_rotate_2=([100]=5 [103]='6 7' [107]=xo [110]=1 [134]=2)
    assert_array 'a' array array_rotate_2 ; bit_set ret 1 $? 
    local -a array=([100]=1 [103]=2 [107]=5 [110]='6 7' [134]=xo)
    array_rotate array -1
    local -a array_rotate__1=([100]=xo [103]=1 [107]=2 [110]=5 [134]='6 7')
    assert_array 'a' array array_rotate__1 ; bit_set ret 2 $? 
    local -a array=([100]=1 [103]=2 [107]=5 [110]='6 7' [134]=xo)
    array_rotate array -2
    local -a array_rotate__2=([100]='6 7' [103]=xo [107]=1 [110]=2 [134]=5)
    assert_array 'a' array array_rotate__2 ; bit_set ret 3 $? 

    if ((ret)) ; then
        echo "${FUNCNAME[0]} test fail."
    else
        echo "${FUNCNAME[0]} test pass."
    fi
    return $ret
}

test_case1

