#!/usr/bin/bash

_test_sed_be_no_border_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./sed/sed_be_no_border.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_sed_be_no_border_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local test_str=''
    {
    IFS= read -r -d '' test_str <<'    EOF'
start before 1
start before 2
start before 3
start before 4
we start
geg gege 
111 111
hahah geg 
中文 中文
we end   
start after 1
start after 2
start after 3
start after 4
    EOF
    } || true

    local ret_spec='geg gege 
111 111
hahah geg 
中文 中文'
    
    local ret_str1= ret_str2=
    ret_str1=$(echo "$test_str" | sed_be_no_border_i 'we start' 'we end')
    local tmp_file=$(mktemp)
    echo "$test_str" >"$tmp_file"
    ret_str2=$(sed_be_no_border_f "$tmp_file" 'we start' 'we end')

    rm -f "$tmp_file"

    if [[ "$ret_str1" == "$ret_spec" ]] && [[ "$ret_str2" == "$ret_spec" ]] ; then
        echo "${FUNCNAME[0]} pass"
    else
        echo "${FUNCNAME[0]} fail"
        return 1
    fi

    return 0
}

test_case1

