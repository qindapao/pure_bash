#!/usr/bin/bash

_test_function_params_old_dir="$PWD"
root_dir="${_test_function_params_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./date/date_log.sh || return 1
. ./array/array_copy.sh || return 1
. ./atom/atom_my.sh || return 1
. ./log/log_dbg.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_function_params_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="


test_case2 ()
{
    local a=$1 b=$2 c=$3
    m=$b
    k=$a
    l=$c
    declare -p a b c m k l

    myp -u {a,b,c,d,e,f,g,h}=\${$((i++))}
    mya -u arr=("${@}")
    ldebug_p '' a b c d e f
}

test_case1 ()
{
    test_case2 "${@}"
    b='1 2 3'
    a=$b
}

test_case3 ()
{
    local - ; set +h
    echo $-
    test_case4
}

test_case4 ()
{
    echo $-
}

test_case1 '*' '3
4' '!' 'xxyy' '1 2' '3 4' 5 6 7 8 9 10 11 12 13
declare -p a b c d

echo $-
test_case3
echo $-

