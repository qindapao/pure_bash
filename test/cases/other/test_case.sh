#!/usr/bin/bash

_test_case_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./date/date_log.sh || return 1
. ./array/array_copy.sh || return 1
. ./atom/atom_my.sh || return 1
. ./log/log_dbg.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_case_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    a=2

    case $a in
        1)
            echo 1
            ;;
        2)
            echo 2
            ;&
        3)
            echo 3
            ;&
        4)
            echo 4
            ;;
        *)
            echo 'other'
            ;;
    esac
}

test_case2 ()
{
    a=2

    case $a in
        1|2)
            echo 1
            ;;&
        2)
            echo 2
            ;;
        3)
            echo 3
            ;;
        4)
            echo 4
            ;;
        *)
            echo 'other'
            ;;
    esac
}



test_case1
test_case2

