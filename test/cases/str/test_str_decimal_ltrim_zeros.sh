#!/usr/bin/bash

_test_str_decimal_ltrim_zeros_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_to_array.sh || return 1
. ./str/str_decimal_ltrim_zeros.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_decimal_ltrim_zeros_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local a='0000435' b='-0000456' c='+0000788'
    local d='456' e='-456' f='+789'
    local x1='0000340045'
    local x2='-0000340045'
    local x3='+0000340045'

    str_decimal_ltrim_zeros_s "$a" a
    str_decimal_ltrim_zeros_s "$b" b
    str_decimal_ltrim_zeros_s "$c" c
    str_decimal_ltrim_zeros_s "$d" d
    str_decimal_ltrim_zeros_s "$e" e
    str_decimal_ltrim_zeros_s "$f" f
    str_decimal_ltrim_zeros_s "$x1" x1
    str_decimal_ltrim_zeros_s "$x2" x2
    str_decimal_ltrim_zeros_s "$x3" x3
    if [[ "$a" == 435 ]] \
        && [[ "$b" == -456 ]] \
        && [[ "$c" == 788 ]] \
        && [[ "$d" == 456 ]] \
        && [[ "$e" == -456 ]] \
        && [[ "$f" == 789 ]] \
        && [[ "$x1" == 340045 ]] \
        && [[ "$x2" == -340045 ]] \
        && [[ "$x3" == 340045 ]] ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
    fi
}


test_case2 ()
{
    local a='0000435' b='-0000456' c='+0000788'
    local d='456' e='-456' f='+789'
    local x1='0000340045'
    local x2='-0000340045'
    local x3='+0000340045'

    a=$(str_decimal_ltrim_zeros_s "$a")
    b=$(str_decimal_ltrim_zeros_s "$b")
    c=$(str_decimal_ltrim_zeros_s "$c")
    d=$(str_decimal_ltrim_zeros_s "$d")
    e=$(str_decimal_ltrim_zeros_s "$e")
    f=$(str_decimal_ltrim_zeros_s "$f")
    x1=$(str_decimal_ltrim_zeros_s "$x1")
    x2=$(str_decimal_ltrim_zeros_s "$x2")
    x3=$(str_decimal_ltrim_zeros_s "$x3")
    if [[ "$a" == 435 ]] \
        && [[ "$b" == -456 ]] \
        && [[ "$c" == 788 ]] \
        && [[ "$d" == 456 ]] \
        && [[ "$e" == -456 ]] \
        && [[ "$f" == 789 ]] \
        && [[ "$x1" == 340045 ]] \
        && [[ "$x2" == -340045 ]] \
        && [[ "$x3" == 340045 ]] ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
    fi
}

test_case1
ret1=$?
test_case2
ret2=$?

! ((ret1|ret2))

