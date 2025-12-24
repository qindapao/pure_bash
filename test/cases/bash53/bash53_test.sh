#!/usr/bin/bash

_test_base64_old_dir=$PWD
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./base64/base64_encode.sh || return 1
. ./base64/base64_decode.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_base64_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set 是否会重置所有命令行参数
test_case1 ()
{
    set -- 1 2 3
    if [[ "$1" == 1 && "$2" == 2 && "$3" == 3 && -z "$4" && -z "$5" ]] ; then
        echo "${FUNCNAME[0]} test pass."
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
    return 0
}

test_case2 ()
{
    # 内部命令新的方式更快
    time echo "${ printf "%s\n" "Holle World!";}"
    time echo "$(printf "%s\n" "Holle World!")"

    # 外部命令两者的速度相同
    time echo "$(ls -l)"
    time echo "${ ls -l;}"
}

test_case3 ()
{
    echo "${ ls -l | grep bash | grep sh; }"
    echo "${|ls -l | grep bash | grep sh;}"
    local var1="${ ls -l | grep bash | grep sh; }"
    local var2="${|ls -l | grep bash | grep sh;}"
    if [[ -n "$var1" && -z "$var2" ]] ; then
        echo "${FUNCNAME[0]} test pass."
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
    return 0
}

# 数组的序列化传参和直接传参数的速率比较
# 直接传的速率要快那么一点点，但是不那么明显
test_case4 ()
{
    test_case4_direct ()
    {
        local -a get_arr=("$@")
        return 0
    }

    test_case4_serilize ()
    {
        eval -- local -a get_arr=($1)
        return 0
    }

    local -a my_arr=()
    local -i i
    for i in {0..1000} ; do
        my_arr+=("$i")
    done
    time test_case4_serilize "${my_arr[*]@Q}"
    time test_case4_direct "${my_arr[@]}"
}

test_case5_get_value2 ()
{
    REPLY=1
}

test_case5_get_value1 ()
{
    test_case5_get_value2
}

test_case5 ()
{
    local get_value=${|test_case5_get_value1;}
    if [[ -z "$REPLY" && "$get_value" == "1" ]] ; then
        echo "${FUNCNAME[0]} test pass."
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
    return 0
}

# 使用关联数组给函数传参
# 1: 直接传关联数组
test_case6 ()
{
    local -a param_list=("$@")
    local -A params
    params=("${param_list[@]}" )
    declare -p params
    echo "${params[test_mode]}"
    echo "${params[test_condition]}"
    echo "${params[test_xx]}"
}

# 使用关联数组给函数传参
test_case7 ()
{
    eval -- local -A params=($1)
    declare -p params
}

declare -A params=(["key 1"]="value 1" ["key 2"]="value 2" ["key 3"]="value 3")
k=("${params[@]@P}")
declare -p k

test_case1 a b c d e &&
test_case2 &&
test_case3 &&
test_case4 &&
test_case5 &&
test_case6 "${params[@]@k}" &&
test_case7 "${params[*]@K}"
test_case6  "test_mode" "xx" "test_condition" "yy" "test_xx" "yy"
            

