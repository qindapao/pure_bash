#!/usr/bin/bash

_test_array_stable_sort_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_stable_sort.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_stable_sort_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local a=(3:5:6 1:7:9  3:5:2 5:10:0 2:6:1 4:5:6)
    array_stable_sort a ':' '-k1,1n' '-k2,2n' '-k3,3n'
    declare -a ret_a=([0]="1:7:9" [1]="2:6:1" [2]="3:5:2" [3]="3:5:6" [4]="4:5:6" [5]="5:10:0")

    if assert_array 'a' a ret_a ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi

    return 0
}

test_case2 ()
{
    local a=(3.5:5.2:-6 1.1:7.3:9.4 3.5:5.2:2.1 5.0:10.0:0.0 2.6:6.1:1.2 4.5:5.6:6.7)
    array_stable_sort a ':' '-k1,1n' '-k2,2n' '-k3,3n'
    declare -a ret_a=([0]="1.1:7.3:9.4" [1]="2.6:6.1:1.2" [2]="3.5:5.2:-6" [3]="3.5:5.2:2.1" [4]="4.5:5.6:6.7" [5]="5.0:10.0:0.0")
    if assert_array 'a' a ret_a ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi

    return 0
}

test_case3 ()
{
    local a=(3a:5b:6c 1a:7b:9c 3a:5b:2c 5a:10b:0c 2a:6b:1c 4a:5b:6c)
    array_stable_sort a ':' '-k1,1' '-k2,2' '-k3,3'
    declare -a ret_a=([0]="1a:7b:9c" [1]="2a:6b:1c" [2]="3a:5b:2c" [3]="3a:5b:6c" [4]="4a:5b:6c" [5]="5a:10b:0c")
    if assert_array 'a' a ret_a ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi

    return 0
}

test_case4 ()
{
    local a=(3:5:6 3:5:9 3:5:2 3:5:0 3:5:1 "3:5:6 ggge:g")
    array_stable_sort a ':' '-k1,1n' '-k2,2n' '-k3,3n'
    declare -a ret_a=([0]="3:5:0" [1]="3:5:1" [2]="3:5:2" [3]="3:5:6" [4]="3:5:6 ggge:g" [5]="3:5:9")
    if assert_array 'a' a ret_a ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi

    return 0
}

test_case5 ()
{
    local a=''
    a+="3:5:6"$'\n'"3:5:9"$'\n'"3:5:2"$'\n'"3:5:0"$'\n'"3:5:1"$'\n'"3:5:6 ggge:g"
    array_stable_sort a ':' '-k1,1n' '-k2,2n' '-k3,3n'
    declare -a ret_a=([0]="3:5:0" [1]="3:5:1" [2]="3:5:2" [3]="3:5:6" [4]="3:5:6 ggge:g" [5]="3:5:9")
    if assert_array 'a' a ret_a ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi

    return 0
}

ret_str=''
test_case1
ret_str+="$?|"
test_case2
ret_str+="$?|"
test_case3
ret_str+="$?|"
test_case4
ret_str+="$?|"
test_case5
ret_str+="$?"

! ((ret_str))

