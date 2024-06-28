#!/usr/bin/bash

_test_trap_sort_old_dir="$(pwd)"
root_dir="${_test_trap_sort_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
# . ./log/log_dbg.sh || return 1
# . ./date/date_log.sh || return 1
. ./trap/trap_set.sh || return 1

cd "$root_dir"/test/lib
# . ./assert/assert_array.sh || return 1

cd "$_test_trap_sort_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="



IS_ALLOW_TRAP_SET=1
eval $(trap_set 1 ERR)
eval $(trap_set 1 RETURN)
eval $(trap_set 1 EXIT)
eval $(trap_set 1 DEBUG)

# eval $(trap_set 0 ERR)
# eval $(trap_set 0 RETURN)
# eval $(trap_set 0 EXIT)
# eval $(trap_set 0 DEBUG)
A=1
B=2
trap_global_vars 1 A B
echo ''

example_function() {
    echo "This is a function."
    ls -l | grep 2
    ls -l | grep 2
    ls -l | grep 2
    ls -l | grep 2
    ls -l | grep 2
    ls -l | grep 2
    ls -l | grep 2
    # 语法错误：缺少结束引号
    echo "This line has a syntax error"
    echo "This line has a syntax error"
    declare -a xx=(1 3)
}





other_func ()
{
    trap_local_vars 1 a b c
    local a=0 b=1 c=2
    echo "xx" | grep qinqing
    other_func2
    return 0
}

other_func2 ()
{
    trap_local_vars 1 d e f
    local d=1 e=2 f=3
    other_func3
    return 0
}

other_func3 ()
{
    local g h
    echo '' | grep "xx"
    return 1
}

dont ()
{
    echo "don"
}

dont2 ()
{
    echo "don"
}


ex ()
{
    qx
}

qx ()
{
    echo "3"
}

echo "This line has a syntax error"
echo "This line has a syntax error"
echo "This line has a syntax error"

xx_len="qinqin"

# 最终命令成功,但是管道中失败,陷阱无法捕捉
mm=$(echo '' | echo '' | echo '' | echo '' | grep foo | grep xx)
echo "mm:$?"
echo "prams:$-"

other_func
ls
ls
ls
ls
example_function
echo "1"
echo "2"

test_ ()
{
    : 5 6
}

echo '4' | grep 4
: 3 4 5 7
echo "_:${_}"
if echo '3' | grep 4 ; then
    echo "_:x"
else
    echo "_:y"
fi

ex
exit 0

