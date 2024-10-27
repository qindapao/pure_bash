#!/usr/bin/bash

_test_str_tr_cr_to_space_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_tr_cr_to_space.sh || return 1
. ./cntr/cntr_map.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_tr_cr_to_space_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    local str1=$'/root/xx/yy/tnt.t\nxt\n\r\r\r'
    local str1_after='/root/xx/yy/tnt.t xt    '

    str_tr_cr_to_space str1
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
    local -a array=($'\r\n/ro\rot/xx/y  y/t\nnt.txt' $'/g\nege/g  ege/k\rk/yy.txt' $'/g\rge/g\neg/yy.ini')
    local -a array_after=('  /ro ot/xx/y  y/t nt.txt' '/g ege/g  ege/k k/yy.txt' '/g ge/g eg/yy.ini')
    cntr_map array str_tr_cr_to_space
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
    local str=$(printf "%s" $'ggeg\r\r\r\n\r\nggeg geg' | str_tr_cr_to_space)
    if [[ "$str" == 'ggeg      ggeg geg' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case2 &&
test_case3

