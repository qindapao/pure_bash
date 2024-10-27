#!/usr/bin/bash

_test_str_join_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_join.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_join_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx

test_case1 ()
{
    local -a array=('1 2' '3 4' 'a b' e d fff dx)
    local str str2 str3
    str_join -v str '-+' "${array[@]}"
    local -a array2=()
    local -a array3=('x o')
    str_join -v str2 '--' "${array2[@]}"
    str_join -v str3 '--' "${array3[@]}"
    
    if [[ "$str" == '1 2-+3 4-+a b-+e-+d-+fff-+dx' ]] &&
        [[ "$str2" == '' ]] &&
        [[ "$str3" == 'x o' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

