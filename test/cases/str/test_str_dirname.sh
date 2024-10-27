#!/usr/bin/bash

_test_str_dirname_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_dirname.sh || return 1
. ./cntr/cntr_map.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_dirname_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    local str1='/root/xx/yy/tnt.txt'
    local str1_after='yy'

    str_dirname str1
    if [[ "$str1" == "$str1_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local -a array=('/root/xx/y  y/tnt.txt' '/gege/g  ege/kk/y y.txt' '/gge/geg/yy.ini')
    local -a array_after=('y  y' 'kk' 'geg')
    cntr_map array str_dirname
    if assert_array 'a' array array_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case3 ()
{
    local str1=$(echo '/root/xx/yy/tnt.txt' | str_dirname)
    local str1_after='yy'

    if [[ "$str1" == "$str1_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case4 ()
{
    local -A dict=(['xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)
geg']='/root/xx/y  y/tnt.txt' [my]='/gege/g  ege/kk/y y.txt' [my2]='/gge/geg/yy.ini')
    local -A dict_after=(['xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)
geg']='y  y' [my]='kk' [my2]='geg')
    cntr_map dict str_dirname
    if assert_array 'A' dict dict_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case2 &&
test_case3 &&
test_case4

