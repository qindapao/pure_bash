#!/usr/bin/bash

_test_double_brackets_old_dir="$PWD"
root_dir="${_test_double_brackets_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_copy.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_double_brackets_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

alias xx="date +'%Y_%m_%d_%H_%M_%S'"

# 测试[[]] 里面是空字符串返回假
test_case1 ()
{
    [[ '' ]]
    if (($?)) ; then
        # 假
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
    fi
}

# 这个用例应该放到双圆括号的文件中,不应该出现在这里
# :TODO: 测试关联数组 ((assoc${-+[}$key]++)) 语法可用
test_case2 ()
{
    :
}


test_case1
test_case2

