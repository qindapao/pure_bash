#!/usr/bin/bash

_test_dict_unset_prefix_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./dict/dict_unset_prefix.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_dict_unset_prefix_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local -A dict_a=([xx_1]=1 [23ggge]=4 [xx2]=3 [gge23]=5 [xx_yy]=1 [xx45dgeg]=43 [yyuu]=4)
    local -A dict_ret=([23ggge]="4" [gge23]="5" [yyuu]="4")
    local key1='' key2='xx'
    local ret1 ret2
    dict_unset_prefix dict_a "$key1"
    ret1=$?
    dict_unset_prefix dict_a "$key2"
    ret2=$?

    if ((ret1)) && ! ((ret2)) && assert_array 'A' dict_a dict_ret  ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi

    return 0
}

test_case1

