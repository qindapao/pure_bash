#!/usr/bin/bash

_test_array_dump_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./array/array_dump.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_array_dump_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local -a arr1=(5 6 1 "ab cd" "12 34")
    local -a arr2=()
    local -a arr3
    local -A dict1=(['a b c d']='12 34' [key1]=value1 [key2]=value2 [key4]=5)
    local -A dict2=()
    local str1="gege"
    local str2=''
    local str3
    local -i num1=34

    local dump_str_arr1 dump_str_arr2 dump_str_dict1 dump_str_dict2
    local dump_str_str1 dump_str_str2 dump_str_str3 dump_str_num1
    local dump_str_arr3

    local all_str=''

    array_dump arr1 dump_str_arr1
    all_str+="$dump_str_arr1"
    array_dump arr2 dump_str_arr2
    all_str+="$dump_str_arr2"
    array_dump arr3 dump_str_arr3
    all_str+="$dump_str_arr3"

    array_dump dict1 dump_str_dict1
    all_str+="$dump_str_dict1"
    array_dump dict2 dump_str_dict2
    all_str+="$dump_str_dict2"
    array_dump str1 dump_str_str1
    all_str+="$dump_str_str1"
    array_dump str2 dump_str_str2
    all_str+="$dump_str_str2"
    array_dump str3 dump_str_str3
    all_str+="$dump_str_str3"
    array_dump num1 dump_str_num1
    all_str+="$dump_str_num1"

    local spec_str=''
    {
    IFS= read -r -d '' spec_str <<'    EOF'
arr1(-a) :=
    0 = 5
    1 = 6
    2 = 1
    3 = ab cd
    4 = 12 34
arr2(-a) :=
arr3(-a) :=
dict1(-A) :=>
    a b c d => 12 34
    key1 => value1
    key2 => value2
    key4 => 5
dict2(-A) :=>
-- str1="gege"
-- str2=""
-- str3
-i num1="34"
    EOF
    } || true

    if [[ "$all_str" == "$spec_str" ]] ; then
        echo "${FUNCNAME[0]} test pass."
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
    
    return 0
}

test_case2 ()
{
    local -n arr1_ref1=arr1_ref2
    local -n arr1_ref2=arr1_ref3
    local -n arr1_ref3=arr1

    local -n arr2_ref1=arr2

    local -ai arr1=(5 6 1 1000 100)
    local -a arr2=()
    
    local -n arr3_ref1=arr3

    local -a arr3

    local -n dict1_ref1=dict1

    local -A dict1=(['a b c d']='12 34' [key1]=value1 [key2]=value2 [key4]=5)
    local -n dict2_ref1=dict2
    local -A dict2=()
    local -n str1_ref1=str1
    local str1="gege"
    local -n str2_ref1=str2
    local str2=''
    local -n str3_ref1=str3
    local str3
    local -n num1_ref1=num1
    local -i num1=34

    local dump_str_arr1 dump_str_arr2 dump_str_dict1 dump_str_dict2
    local dump_str_str1 dump_str_str2 dump_str_str3 dump_str_num1
    local dump_str_arr3

    local all_str=''

    array_dump arr1_ref1 dump_str_arr1
    all_str+="$dump_str_arr1"
    array_dump arr2_ref1 dump_str_arr2
    all_str+="$dump_str_arr2"
    array_dump arr3_ref1 dump_str_arr3
    all_str+="$dump_str_arr3"

    array_dump dict1_ref1 dump_str_dict1
    all_str+="$dump_str_dict1"
    array_dump dict2_ref1 dump_str_dict2
    all_str+="$dump_str_dict2"

    array_dump str1_ref1 dump_str_str1
    all_str+="$dump_str_str1"
    array_dump str2_ref1 dump_str_str2
    all_str+="$dump_str_str2"
    array_dump str3_ref1 dump_str_str3
    all_str+="$dump_str_str3"
    array_dump num1_ref1 dump_str_num1
    all_str+="$dump_str_num1"

    local spec_str=''
    {
    IFS= read -r -d '' spec_str <<'    EOF'
arr1_ref1->arr1_ref2->arr1_ref3->arr1(-ai) :=
    0 = 5
    1 = 6
    2 = 1
    3 = 1000
    4 = 100
arr2_ref1->arr2(-a) :=
arr3_ref1->arr3(-a) :=
dict1_ref1->dict1(-A) :=>
    a b c d => 12 34
    key1 => value1
    key2 => value2
    key4 => 5
dict2_ref1->dict2(-A) :=>
str1_ref1->str1 -- str1="gege"
str2_ref1->str2 -- str2=""
str3_ref1->str3 -- str3
num1_ref1->num1 -i num1="34"
    EOF
    } || true

    if [[ "$all_str" == "$spec_str" ]] ; then
        echo "${FUNCNAME[0]} test pass."
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
    return 0
}

all_ret=0
test_case1 || all_ret=1
# 多级引用变量的情况
test_case2 || all_ret=1

exit $all_ret

