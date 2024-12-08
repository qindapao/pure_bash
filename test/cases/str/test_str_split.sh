#!/usr/bin/bash

_test_str_split_old_dir="$PWD"
root_dir="${_test_str_split_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_split.sh || return 1
. ./cntr/cntr_map.sh || return 1
. ./atom/atom_func_upstr.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_split_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local -a array=('--x-' '--yk1-' '--geg*-')
    local -a array_after=(x yk1 'geg*')
    cntr_map array str_split_a '-' 3
    if assert_array a 'array' array_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

# 为了兼容bash4.4,带有别名的执行在子进程中最好用eval来执行
test_case2 ()
{
    local str1=" xxoo223ooxx"
    local str_get=$(echo "$str1" | eval ${BASH_ALIASES[str_split_i]} 'oo' 2)
    if [[ "$str_get" == '223' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case3 ()
{
    local str1=" xxoo223ooxx"
    local str_get=$(eval ${BASH_ALIASES[str_split_s]} '"$str1"' oo 2)
    if [[ "$str_get" == '223' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}


test_case4 ()
{
    local str1=" xxoo223ooxx"
    local ret_str
    
    atom_func_upstr ret_str \
        str_split_sv "$str1" oo 2
    if [[ "$ret_str" == '223' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

ret=0
test_case1
((ret|=$?))
test_case2
((ret|=$?))
test_case3
((ret|=$?))
test_case4
((ret|=$?))

exit $ret

