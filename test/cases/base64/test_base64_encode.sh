#!/usr/bin/bash

_test_base64_encode_old_dir=$PWD
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./base64/base64_encode.sh || return 1
. ./base64/base64_decode.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_base64_encode_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local start end i

    local test_str="test string ggegg
    gegeg
    gegegg
    
    " 

    for i in {1..6} ; do
        test_str+="$test_str"
    done
    echo "str len:${#test_str}"

    for i in {1..2}; do
        # time out_str=$(base64<<<"$test_str")
        time out_str=$(base64_encode<<<"$test_str")
        time out_str=$(printf "%s" "$test_str" |base64_encode)
    done
    
    printf "%s\n" "$out_str"
}

test_case1

