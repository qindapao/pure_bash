#!/usr/bin/bash

_test_str_decimal_ltrim_zeros_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_decimal_ltrim_zeros.sh || return 1
. ./cntr/cntr_map.sh || return 1

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

    str_decimal_ltrim_zeros  a
    str_decimal_ltrim_zeros  b
    str_decimal_ltrim_zeros  c
    str_decimal_ltrim_zeros  d
    str_decimal_ltrim_zeros  e
    str_decimal_ltrim_zeros  f
    str_decimal_ltrim_zeros x1
    str_decimal_ltrim_zeros x2
    str_decimal_ltrim_zeros x3
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

    a=$(echo "$a" | str_decimal_ltrim_zeros)
    b=$(echo "$b" | str_decimal_ltrim_zeros)
    c=$(echo "$c" | str_decimal_ltrim_zeros)
    d=$(echo "$d" | str_decimal_ltrim_zeros)
    e=$(echo "$e" | str_decimal_ltrim_zeros)
    f=$(echo "$f" | str_decimal_ltrim_zeros)
    x1=$(echo "$x1" | str_decimal_ltrim_zeros)
    x2=$(echo "$x2" | str_decimal_ltrim_zeros)
    x3=$(echo "$x3" | str_decimal_ltrim_zeros)
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

test_case3 ()
{
    local -a array=(-0000233 +00323 000999 765)
    local -a array_after=(-233 323 999 765)
    cntr_map array str_decimal_ltrim_zeros
    if assert_array 'a' array array_after ; then
        echo "${FUNCNAME[0]} pass."
        return 0
    else
        echo "${FUNCNAME[0]} fail."
        return 1
    fi
}


test_case1
ret1=$?
test_case2
ret2=$?
test_case3
ret3=$?

! ((ret1|ret2|ret3))

