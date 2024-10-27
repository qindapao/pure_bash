#!/usr/bin/bash

_test_str_is_not_black_or_empty_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_is_not_black_or_empty.sh || return 1
. ./cntr/cntr_grep.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_is_not_black_or_empty_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    local ret=''
    local str1='/root/xx/yy/tnt.txt'
    str_is_not_black_or_empty "$str1" ; ret="$?$ret"
    str_is_not_black_or_empty  '  '  ; ret="$?$ret"
    str_is_not_black_or_empty  '
'  ; ret="$?$ret"
    str_is_not_black_or_empty $'\t'  ; ret="$?$ret"

    if [[ "$ret" == '1110' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

}

test_case2 ()
{
    local -a array=('/root/xx/y  y/tnt.txt' '' '     '  '   ' '/gge/geg/yy.ini')
    local -a array_after=('/root/xx/y  y/tnt.txt' '/gge/geg/yy.ini')
    cntr_grep array str_is_not_black_or_empty
    if assert_array 'a' array array_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case2

