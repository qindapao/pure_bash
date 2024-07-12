#!/usr/bin/bash

_test_array_all_old_dir="$PWD"
root_dir="${_test_array_all_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_sort.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_all_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="


# 验证eval和函数别名的结合使用

test_func () 
{
    echo $1
    echo $2
    echo $3
    echo $4
    echo $5
    shift 5

    local my_other=("${@}")
    declare -p my_other
}

a='1 2'
b='3 4'


m='test_func "x y"'
other=('a1 a2' 'b1 b2' 'c1 c2')

declare -A e=(['hah haha']='xx oo' ['yha yha']='woei wo')
i='yha yha'


eval $m '"$a"' '"$b"' '"${e[$i]}"' '"${other[@]}"'

