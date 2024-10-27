#!/usr/bin/bash

_test_atom_upvars_old_dir="$PWD"
root_dir="${_test_atom_upvars_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./atom/atom_upvars.sh || return 1
. ./cntr/cntr_kv.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_atom_upvars_old_dir"

# set -xv

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 () 
{
    local -A case1=()
    local -a case3=()
    local xx
    test_case2 'case1' 'case3' 'xx'

    local -A case1_after=([xx]=2)
    local -a case3_after=(1)
    local xx_after='12 3'
    local ret=0

    assert_array 'A' case1 case1_after ; ret=$?
    assert_array 'a' case3 case3_after ; ret=$?$ret
    [[ "$xx" == "$xx_after" ]] ; ret=$?$ret

    if [[ "$ret" == '000' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail.ret:${ret};"
        return 1
    fi
}

test_case2 ()
{
    local -a case1=([0]=1)
    local -A case3=([xx]=2)
    # local -A case2=([fond]=1 [xx]=2 ['xx yy']=' 344' ['ggeeg
    # gege geg']='ggeg
    # gege')
    # local -A case2=([fond]=1 [xx]=2 ['xxyy']=' 344')
    local -A case2=()
    local -a my_kv ; cntr_kv my_kv case3
    # local -a case3=('gegeg')
    # 下面的local声明是必不可少的
    local "$@" && atom_upvars -A${#case3[@]} "$1" "${my_kv[@]}" -a${#case1[@]} "$2" "${case1[@]}" -v "$3" '12 3'
}

test_case1

