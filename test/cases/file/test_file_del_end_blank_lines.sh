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

rm -f mock_file.txt

test_case1 ()
{
    echo "" >>mock_file.txt
    echo "" >>mock_file.txt
    echo "" >>mock_file.txt
    echo "" >>mock_file.txt
    echo "xxyy" >>mock_file.txt
    echo "yyqq" >>mock_file.txt
    echo "" >>mock_file.txt
    echo "" >>mock_file.txt
    echo "         " >>mock_file.txt
    echo "         " >>mock_file.txt
    echo "" >>mock_file.txt
    echo "" >>mock_file.txt
    echo "" >>mock_file.txt
    file_del_end_blank_lines mock_file.txt >mock_file1.txt
}

test_case1 >log.txt 2>&1

