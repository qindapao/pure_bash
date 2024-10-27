#!/usr/bin/bash

_test_awk_grep_prefix_after_old_dir=$PWD
root_dir="${_test_awk_grep_prefix_after_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./awk/awk_grep_prefix_after.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_awk_grep_prefix_after_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# 匹配场景
test_case1 ()
{
    local str='
    nggege
    geg
geg
1 2 3
xx oo
1 45
haha ha
'
    local str_after='xx oo
1 45
haha ha'
    
    local str_conv=$(echo "$str" |awk_grep_prefix_after 'xx oo')

    if [[ "$str_conv" == "$str_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi   
}

# 不匹配场景
test_case2 ()
{
    local str='
    nggege
    geg
geg
1 2 3
 xx oo
1 45
haha ha
'
    local str_after=''
    
    local str_conv=$(echo "$str" |awk_grep_prefix_after 'xx oo')

    if [[ "$str_conv" == "$str_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi   
}

# 中文场景
test_case3 ()
{
    local str='
    nggege
    geg
geg
1 2 3
中文
1 45
haha ha
'
    local str_after='中文
1 45
haha ha'
    
    local str_conv=$(echo "$str" |awk_grep_prefix_after '中文')

    if [[ "$str_conv" == "$str_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi   
}


test_case1 &&
test_case2 &&
test_case3

