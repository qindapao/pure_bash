#!/usr/bin/bash

set +E

_test_trap_try_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
# . ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./nfor/nfor.sh || return 1

cd "$root_dir"/test/lib
# . ./assert/assert_array.sh || return 1

cd "$_test_trap_try_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="
# set -x

test_case1 ()
{
    a='* 1 2
* 3 4
* 5 6'
    
    nfor i in $a ; ndo
        for j in $a ; do
            echo "$j"
        done
        echo "$i"
    ndone
}

nfor_func ()
{
    local localx="a b c
e f f
* 2 3"

    declare -p localx

    nfor i in $localx ; ndo
        echo "nfor i:$i"
    ndone
    
    for i in $localx ; do
        echo "for i:$i"
    done
}

test__ ()
{
    set -x
    echo "inner global -:${-}"
    local -
    echo "inner before -:${-}"
    set +hBx
    echo "inner after -:${-}"
}


test_1 ()
{
    declare a=1
    echo $a
    test_2
    echo $a
}

test_2 ()
{
    local a=2
    echo $a
}

test_param_list ()
{
    a="1 2 3
4 5 6
7 8 9"
    nfor i in $a ; ndo
        a=''
        echo "i:$i"
    ndone

    echo "a:$a"
}

test_param_num ()
{
    echo "${@}"
    local param="${1}"
    shift
    param_arr=("${@}")
    echo "${param_arr[@]}"
    echo "${@:1:$#-2}"
    echo "${param_arr[@]::$#-2}"
    echo "${@:$#-1}"
}

test_params_2 ()
{
    echo "${@:1:$#-2}"
    echo "${@:$#-1:1}"
    echo "${@:$#:1}"

    ((1)) && {
        ((0)) || echo 1
    } || echo 0

}

test_big_array ()
{
    local i
    local -a big_arr=()
    local big_str=''
    echo 1
    for ((i=0;i<100000;i++)) ; do
        big_arr+=("bigarr bigarr bigarr bigarr bigarr")
        echo "$i"
    done
    echo 2
    printf "%s" "${big_arr[@]@A}"
}

test__ ()
{
    local -
    set +h
    test2
    echo $-
}

test2 ()
{
    local -
    set -h
    test3
    echo $-
}

test3 ()
{
    local -
    echo $-
}

test_bool ()
{
    i=0
    ((i<=0))
}

test_nfor_special ()
{
    local a='1
    gge geg * 
    a 2 * * '
    local b='12 3 
    a b c * * '
    local c='xx xy
    gg ge * ! (  )'


    m=$(printf "%q" "$a")
    m+=$'\n'
    m+=$(printf "%q" "$b")
    m+=$'\n'
    m+=$'\n'
    m+=$'\n'
    m+=$'\n'
    m+=$'\n'
    m+=$'\n'
    m+=$(printf "%q" "$c")
    m+=$'\n'
    m+=$'\n'
    m+=$'\n'
    
    declare -p m
    
    local iter
    nfor iter in $m ; ndo
        # 这里iter2和iter相同
        eval iter2="\$iter"
        # 这里的引号是必须的,不然扩展还会发生
        # 这里iter展开一次后的结果
        eval iter="$iter"
        declare -p iter iter2
    ndone
}

test_case_disable ()
{
    echo "${FUNCNAME[0]} is disabled."
}

test_case_disable
exit $?

test_nfor_special
exit 0

test_bool
echo "?:$?"
exit 0


test__
echo $-
exit 0


test_big_array
exit 0


test_params_2 1 2 3 4 5 6
exit 0


while a=$(cat 1.txt) ; do
    echo "$a"
    echo "success"
    sleep 1
done
exit 0




test_param_num '1 x' 2 '3 y' 4 5 6
exit 0

# test_1
test_param_list
exit 0



x="1 2 3
4 5 6
7 8 9"


nfor a in $x ; ndo
echo "a:$a"
ndone

global_a=1

nfor_func

echo "final IFS:"
declare -p IFS

test__

echo "out -:${-}"

