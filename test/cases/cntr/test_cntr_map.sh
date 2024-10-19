#!/usr/bin/bash

_test_cntr_map_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./cntr/cntr_map.sh || return 1
. ./str/str_basename.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_cntr_map_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

xx ()
{
    eval $1[\$2]='$(("${3}"+2))'
}
alias yy=xx

map_func ()
{
    eval $1[\$2]='${3}x'
}

test_case1 ()
{
    local ret_code=0
    local -a array=('1 2' '3 4' 5 6)
    local -a array_after=('1 2x' '3 4x' 5x 6x)
    cntr_map array map_func
    assert_array 'a' array array_after
    ret_code=$?
    ((ret_code)) && {
        echo "${FUNCNAME[0]} test fail."
    } || {
        echo "${FUNCNAME[0]} test pass."
    }

    return $ret_code
}

test_case2 ()
{
    local ret_code=0
    local -A dict=(['1 2 34']=xx [$'56 8 \n XX']=yk)
    local -A dict_after=(['1 2 34']=xxx [$'56 8 \n XX']=ykx)
    cntr_map dict map_func
    assert_array 'A' dict dict_after
    ret_code=$?
    ((ret_code)) && {
        echo "${FUNCNAME[0]} test fail."
    } || {
        echo "${FUNCNAME[0]} test pass."
    }
    return $ret_code
}

test_case3 ()
{
    local ret_code=0
    local -A dict=(['1 2 34']=xx [$'56 8 \n XX']=yk)
    local -A dict_after=(['1 2 34']=xxx [$'56 8 \n XX']=ykx)
    cntr_map dict 'eval $1[\$2]='\''"${3}x"'\'''
    assert_array 'A' dict dict_after
    ret_code=$?
    ((ret_code)) && {
        echo "${FUNCNAME[0]} test fail."
    } || {
        echo "${FUNCNAME[0]} test pass."
    }
    return $ret_code
}

test_case4 ()
{
    local ret_code=0

    local -A dict
    dict['gegee(]
    gegexx']='/root/TestPlat/comm/yyyxxd.txt'
    dict['2 44']='/root/1232.txt'
    dict['dgge']='/root/132.txt'
    dict[345dddd]='/root/12.txt'
    local -A dict_after
    dict_after['gegee(]
    gegexx']='yyyxxd'
    dict_after['2 44']='1232'
    dict_after['dgge']='132'
    dict_after[345dddd]='12'

    cntr_map dict str_basename
    if assert_array 'A' dict dict_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

# 测试别名的情况
test_case5 ()
{
    local array=(1 2 3 4)
    local array_after=(3 4 5 6)
    cntr_map array yy
    if assert_array 'a' array array_after ; then
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
test_case3
((ret|=$?))
test_case4
((ret|=$?))
test_case5
((ret|=$?))

exit $ret

