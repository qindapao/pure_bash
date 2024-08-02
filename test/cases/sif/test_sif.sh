#!/usr/bin/bash

_test_sif_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./date/date_log.sh || return 1
. ./array/array_copy.sh || return 1
. ./log/log_dbg.sh || return 1
. ./sif/sif.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_sif_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="
test_sif ()
{
    local a=$1
    sif [[ "$a" == '1' ]] ; then
        echo "1"
    selif [[ "$a" == '2' ]] ; then
        echo '2'
    selif [[ "$a" == '3' ]] ; then
        echo '3'
    selse
        echo '4'
    sfi
}

test_sif_no_selse ()
{
    local a=$1
    sif [[ "$a" == '1' ]] ; then
        echo "1"
    selif [[ "$a" == '2' ]] ; then
        echo '2'
    selif [[ "$a" == '3' ]] ; then
        echo '3'
    selse
    sfi
}

test_case1 ()
{
    local ret_str1='' ret_str2='' ret_str3='' ret_str4=''
    m=k
    k=test_sif
    ret_str1=$(eval eval \"\$"$m '"1"'"\")
    ret_str2=$(eval eval \"\$$m 2\")
    ret_str3=$(test_sif '3')
    ret_str4=$(test_sif '4')
    
    declare -p ret_str1 ret_str2 ret_str3 ret_str4

    if (((ret_str1==1)&&(ret_str2==2)&&(ret_str3==3)&&(ret_str4==4))) ; then
        echo "${FUNCNAME[0]} pass"
        return 0
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
}

test_case2 ()
{
    local ret_str1='' ret_str2='' ret_str3=''
    ret_str1=$(test_sif_no_selse '1')
    ret_str2=$(test_sif_no_selse '2')
    ret_str3=$(test_sif_no_selse '3')
    if (((ret_str1==1)&&(ret_str2==2)&&(ret_str3==3))) ; then
        echo "${FUNCNAME[0]} pass"
        return 0
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi
}

test_case3 ()
{
    local a=1

    local block_str='elif [[ "2" == "$a" ]] ; then
        echo "2"
        echo "2 2"
        echo "2 2 2"
        echo "2 2 2 2"
        echo "2 2 2 2 2"
        echo "2 2 2 2 2 2"
        echo "2 2 2 2 2 2 2" ;'
    local all_block_str
    for i in {0..2495} ; do
        all_block_str+="$block_str"
    done

    local block_str='
        if [[ "3" == "$a" ]] ; then
            echo "3"
        '$all_block_str'
        elif [[ "1" = "$a" ]] ; then
            echo '1'
        fi
    '

    eval "$block_str"

    echo 'end'
}

test_case4 ()
{
    local a=1

    local block_str='elif [[ "2" == "$a" ]] ; then
        echo "2"
        echo "2 2"
        echo "2 2 2" ;'
    local all_block_str
    for i in {0..2496} ; do
        all_block_str+="$block_str"
    done

    local block_str='
        if [[ "3" == "$a" ]] ; then
            echo "3"
        '$all_block_str'
        elif [[ "1" = "$a" ]] ; then
            echo '1'
        fi
    '

    eval "$block_str"

    echo 'end'
}

test_case1
ret1=$?
test_case2
ret2=$?
# 验证大的elif结构
test_case3
test_case4

exit $((ret1|ret2))

