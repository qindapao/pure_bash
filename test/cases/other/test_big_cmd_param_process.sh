#!/usr/bin/bash

_test_str_slice_old_dir="$PWD"
root_dir="${_test_str_slice_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_slice_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="


test_case1 ()
{
    test_case ()
    {
        local my_big_str=("${@}")
        echo "${my_big_str[*]}" 
    }

    local i
    local -a tmp_str=()

    # 生成一个105M的超大数组
    for((i=0;i<1000000;i++)) ; do
        tmp_str+=("i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.i am a big str.")
    done

    get_str=$(test_case "${tmp_str[@]}")
    echo "get_str length:${#get_str}"
    if [[ "${#get_str}" == '105999999' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case_diable ()
{
    echo "${FUNCNAME[0]} test disabled."
}

# 时间太长了常规下不需要执行这个用例
test_case_diable
exit $?
test_case1

