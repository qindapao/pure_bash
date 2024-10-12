#!/usr/bin/bash

_test_bit_save_binary_old_dir="$PWD"
root_dir="${_test_bit_save_binary_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./bit/bit_save_binary.sh || return 1
. ./bit/bit_recover_binary.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_bit_save_binary_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local ret_code=0
    local binary_str=''
    time bit_save_binary binary_str '/usr/bin/tee' 
    time bit_recover_binary "$binary_str" './my-tee'
    if diff ./my-tee /usr/bin/tee ; then
        echo "${FUNCNAME[0]} pass"
        rm -f ./my-tee
    else
        echo "${FUNCNAME[0]} fail"
        ret_code=1
    fi

    return $ret_code
}

test_case2 ()
{
    local ret_code=0
    local -i ret1 ret2
    bit_save_binary 'geg geg' '/usr/bin/tee'
    ret1=$?
    bit_save_binary 'geggeg' ''
    ret2=$?

    if ((ret1&ret2)) ; then
        # 两个都应该失败
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        ret_code=1
    fi

    return $ret_code
}

test_case3 ()
{
    local ret_code=0
    local tmp_file=$(mktemp)
    printf '\0\0\0\0\0' > "$tmp_file"
    local get_str=
    bit_save_binary 'get_str' "$tmp_file"
    local tmp_file2=$(mktemp)
    
    printf "$get_str" > "$tmp_file2"
    if diff "$tmp_file" "$tmp_file2" ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        ret_code=1
    fi
    # rm -f -- "$tmp_file" "$tmp_file2"
    return $ret_code
}

# 这个用例并没有作用,只是临时用来获取二进制文件而已
test_case4 ()
{
    local ibase64_aarch64_str ibase64_x86_str
    bit_save_binary ibase64_aarch64_str "${root_dir}/src/tools/ibase64_aarch64"
    bit_save_binary ibase64_x86_str "${root_dir}/src/tools/ibase64_x86"
    printf "%s\n" "$ibase64_x86_str" >x86.txt
    printf "%s\n" "$ibase64_aarch64_str" >arm.txt
    # 如果需要这两个文件就不要删除
    rm -f -- x86.txt arm.txt
}


ret_str=''
test_case1
ret_str+="$?|"
test_case2
ret_str+="$?|"
test_case3
ret_str+="$?|"
test_case4
ret_str+="$?"

! ((ret_str))

