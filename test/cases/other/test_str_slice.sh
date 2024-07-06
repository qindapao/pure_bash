#!/usr/bin/bash

_test_str_slice_old_dir="$PWD"
root_dir="${_test_str_slice_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_slice_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

a="我是谁"

echo "${a:0:1}"
echo "${a:1:1}"
echo "${a:2:1}"
echo "${a#?}"
echo "${a#??}"
echo "${a#???}"

# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# bash test_str_slice.sh 
# =========test_str_slice.sh test start in 2024_07_04_09_24_30==========
# 我
# 是
# 谁
# 是谁
# 谁

# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# 
#
#
