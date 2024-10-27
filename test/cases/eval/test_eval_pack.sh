#!/usr/bin/bash

_test_eval_pack_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./eval/eval_pack.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_eval_pack_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local ret=''
    local a='gge
gege ggeg '
if ((__META_BASH_VERSION>=4004000)) ; then
    local a_after="${a@Q}"
else
    local a_after
    printf -v a_after "%q" "${a}"
fi
    eval_pack a

    [[ "$a" == "$a_after" ]] && ret="$?$ret"

    local a='gge
gege ggeg '
if ((__META_BASH_VERSION>=4004000)) ; then
    local a_after2="${a@Q}"
    a_after2="${a_after2@Q}"
    a_after2="${a_after2@Q}"
else
    local a_after2
    printf -v a_after2 "%q" "${a}"
    printf -v a_after2 "%q" "${a_after2}"
    printf -v a_after2 "%q" "${a_after2}"
fi
    eval_pack a 3
    [[ "$a" == "$a_after2" ]] && ret="$?$ret"

    if [[ "$ret" == '00' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1

