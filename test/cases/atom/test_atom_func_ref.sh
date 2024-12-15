#!/usr/bin/bash

_test_atom_func_ref_old_dir="$PWD"
root_dir="${_test_atom_func_ref_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./atom/atom_func_ref.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_atom_func_ref_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_func ()
{
    REPLY=''
    local -n var1=$2
    local -n arr1=$4
    local -n var2=$6
    local -n arr2=$8
    local -n dict1=${10}
    local para1=${12}
    local para2=${13}
    local para3=${14}
    local para4=${15}

    var1='var1-str'
    arr1=('arr
        1-1' 'arr1-2')
    var2='var2-str'
    arr2=('arr2-1' 'arr2-2')
    dict1=([dict1-1]='1 2 3' [dict1-2]='1 
        gge ')
    echo "para1:${para1}"
    echo "para2:${para2}"
    echo "para3:${para3}"
    echo "para4:${para4}"
    REPLY="'1 2 3' '
    ggge
    4 5
    '"
}

test_case1 () 
{
    local o_var1=1 o_var2=2
    local -a ret_xx=()
    local -a o_arr1=(xx) o_arr2=(xx)
    local -A o_dict1=([0]=1)

    local ret_xx_after=([0]="1 2 3" [1]=$'\n    ggge\n    4 5\n    ')
    local o_arr1_after=([0]=$'arr\n        1-1' [1]="arr1-2")
    local o_arr2_after=([0]="arr2-1" [1]="arr2-2")
    local -A o_dict1_after=([dict1-1]="1 2 3" [dict1-2]=$'1 \n        gge ' )

    atom_func_ref -oa ret_xx -f \
        test_func -v o_var1 -a o_arr1 -v o_var2 -a o_arr2 -A o_dict1 -p 1 2 3 4

    if [[ "$o_var1" == 'var1-str' ]] &&
       [[ "$o_var2" == 'var2-str' ]] &&
       assert_array 'a' ret_xx ret_xx_after &&
       assert_array 'a' o_arr1 o_arr1_after &&
       assert_array 'a' o_arr2 o_arr2_after &&
       assert_array 'A' o_dict1 o_dict1_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

