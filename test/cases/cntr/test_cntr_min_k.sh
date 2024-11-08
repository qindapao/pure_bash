#!/usr/bin/bash

_test_cntr_min_k_old_dir="$PWD"
root_dir="${_test_cntr_min_k_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./cntr/cntr_min_k.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_cntr_min_k_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local array=(5 2 1 4 5)
    local index
    cntr_min_k array index
    if [[ "$index" == '2' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local -A dict=([xx]=5 [oo]=2 [99]=11 [xui]=4 [9283]=5)
    local index
    cntr_min_k dict index
    if [[ "$index" == 'oo' ]] ; then
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

exit $ret

