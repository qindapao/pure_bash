#!/usr/bin/bash

_test_array_revert_dense_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_revert_dense.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_revert_dense_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local -a arr1=(1 2 3 4 5)
    local -a arr2=('xyz 
gg gge' 'geg geg ge' 'ge' '1')
    local -a arr3=()
    local -a arr4=('dgge 34
 ge gge')
    
    local -a des1=(5 4 3 2 1)
    local -a des2=(1 ge 'geg geg ge' 'xyz 
gg gge')
    local -a des3=()
    local -a des4=('dgge 34
 ge gge')


    array_revert_dense arr1
    array_revert_dense arr2
    array_revert_dense arr3
    array_revert_dense arr4

    local ret_str=''

    assert_array a arr1 des1 
    ret_str+="$?|"
    assert_array a arr2 des2 
    ret_str+="$?|"
    assert_array a arr3 des3 
    ret_str+="$?|"
    assert_array a arr4 des4 
    ret_str+="$?"

    # declare -p ret_str

    if ! ((ret_str)) ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
    fi

    ! ((ret_str))
}

test_case1

