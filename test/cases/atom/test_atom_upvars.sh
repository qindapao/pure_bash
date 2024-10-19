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

set -xv

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 () 
{
    local -A case1=()
    local -a case3=()
    local xx
    test_case2 'case1' 'case3' 'xx'
    declare -p case1 case3 xx
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
    # local -a case3=('gegeg')
    # 下面的local声明是必不可少的
    local "$@" && atom_upvars -A${#case2[@]} "$1" "${case2[@]@k}" -a0 "$2" -v xx '12 3'
}

test_case3 ()
{
    local -A you=(['not found']='gge' ['4xx']=5)
    local -a you_kv ; cntr_kv you_kv you

    local "$@" && atom_upvars -A${#you[@]}  "$1" "${you_kv[@]}"
}

test_case1
declare -A you=(['1 2 3']=4 [xyz]=8 ['ggeg
geg ge']='gge
geg')
test_case3 'you'
declare -p you

