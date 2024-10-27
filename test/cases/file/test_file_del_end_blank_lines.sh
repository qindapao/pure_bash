#!/usr/bin/bash

_test_file_del_end_blank_lines_old_dir="$PWD"
root_dir="${_test_file_del_end_blank_lines_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./file/file_del_end_blank_lines.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_file_del_end_blank_lines_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local ret=0
    local tmp_file1=$(mktemp)
    local tmp_file_result=$(mktemp)
    local tmp_file_spec=$(mktemp)

    echo "" >>"$tmp_file1"
    echo "" >>"$tmp_file1"
    echo "" >>"$tmp_file1"
    echo "" >>"$tmp_file1"
    echo "xxyy" >>"$tmp_file1"
    echo "yyqq" >>"$tmp_file1"
    echo "" >>"$tmp_file1"
    echo "" >>"$tmp_file1"
    echo "         " >>"$tmp_file1"
    echo "         " >>"$tmp_file1"
    echo "" >>"$tmp_file1"
    echo "" >>"$tmp_file1"
    echo "" >>"$tmp_file1"
    file_del_end_blank_lines "$tmp_file1" >"$tmp_file_result"

    echo "" >>"$tmp_file_spec"
    echo "" >>"$tmp_file_spec"
    echo "" >>"$tmp_file_spec"
    echo "" >>"$tmp_file_spec"
    echo "xxyy" >>"$tmp_file_spec"
    echo "yyqq" >>"$tmp_file_spec"

    if diff "$tmp_file_result" "$tmp_file_spec" ; then
        echo "${FUNCNAME[0]} test pass."
    else
        echo "${FUNCNAME[0]} test fail."
        ret=1
    fi

    rm -f "$tmp_file1" "$tmp_file_result" "$tmp_file_spec"
    return $ret
}

test_case1

