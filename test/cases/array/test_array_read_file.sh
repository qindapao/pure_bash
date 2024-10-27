#!/usr/bin/bash

_test_array_read_file_old_dir="$PWD"
root_dir="${_test_array_read_file_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_read_file.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_read_file_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local tmp_file1=$(mktemp) tmp_file2=$(mktemp)
    local -a file_array=()
    local ret=0
    echo "1 2" >>"$tmp_file1"
    echo "3 4" >>"$tmp_file1"
    echo "5 6" >>"$tmp_file1"
    echo "a b" >>"$tmp_file2"
    echo "c d" >>"$tmp_file2"
    echo "e f" >>"$tmp_file2"
    array_read_file 'file_array' "$tmp_file1" "$tmp_file2"
    
    local file_array_after=('1 2' '3 4' '5 6' 'a b' 'c d' 'e f')
    if assert_array 'a' file_array file_array_after ; then
        echo "${FUNCNAME[0]} test pass."
    else
        echo "${FUNCNAME[0]} test fail."
        ret=1
    fi
    rm -f "$tmp_file1" "$tmp_file2"
    return $ret
}

test_case1

