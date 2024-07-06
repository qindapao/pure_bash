#!/usr/bin/bash

_test_localvar_unset_old_dir="$PWD"
root_dir="${_test_localvar_unset_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_localvar_unset_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="


test_case1 ()
{
    local a=test_case1
    test_case2
    declare -p a
}

test_case2 ()
{
    local a=test_case2
    test_case3
    declare -p a
}

test_case3 ()
{
    unset a
    declare -p a
}

test_case4 ()
{
    local -a a=(test_case4)
    test_case5
    declare -p a
}

test_case5 ()
{
    local -a a=(test_case5)
    test_case6
    declare -p a
}

test_case6 ()
{
    local -a a=(test_case6)
    unset a
    declare -p a
}

shopt -s localvar_unset
a=out
test_case1
declare -p a

shopt -u localvar_unset
echo '--------------------------'

a=out
test_case1
declare -p a

echo '----------------------------'

a=(out)
test_case4

