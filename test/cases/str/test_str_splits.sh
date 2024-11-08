#!/usr/bin/bash

_test_str_splits_old_dir="$PWD"
root_dir="${_test_str_splits_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_splits.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_splits_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local str1="1233 xxo yy xxo 4"
    local str2="1233 xxo yy xxo"
    local str3="123434552II"
    local str4="12aBxXo2xC3XXodm1ExxO09"
    local str5="12aBxX12xC3XX2dm1Exx4"
    local ret_code=''
    local -a ret

    local -a spec1=([0]="1233 " [1]=" yy " [2]=" 4")
    local -a spec2=([0]="1233 " [1]=" yy ")
    local -a spec3=([0]="123434552II")
    local -a spec4=([0]="1233" [1]="xxo" [2]="yy" [3]="xxo" [4]="4")
    local -a spec5=([0]="1233" [1]="xxo" [2]="yy" [3]="xxo")
    local -a spec6=([0]="123434552II")
    local -a spec7=([0]="12aB" [1]="2xC3" [2]="dm1E" [3]="09")
    local -a spec8=([0]="12aBxX12xC3XX2dm1Exx4")

    str_splits "$str1" 'xxo'
    assert_array a ret spec1 ; ret_code="$?$ret_code"
    str_splits "$str2" 'xxo'
    assert_array a ret spec2 ; ret_code="$?$ret_code"
    str_splits "$str3" 'xxo'
    assert_array a ret spec3 ; ret_code="$?$ret_code"
    str_splits "$str1"
    assert_array a ret spec4 ; ret_code="$?$ret_code"
    str_splits "$str2"
    assert_array a ret spec5 ; ret_code="$?$ret_code"
    str_splits "$str3"
    assert_array a ret spec6 ; ret_code="$?$ret_code"
    str_splits "$str4" 'xxo' 1
    assert_array a ret spec7 ; ret_code="$?$ret_code"
    str_splits "$str5" 'xxo' 1
    assert_array a ret spec8 ; ret_code="$?$ret_code"

    if [[ "$ret_code" == '00000000' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail. ret code:${ret_code}"
        return 1
    fi
}

test_case1

