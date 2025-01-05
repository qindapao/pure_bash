#!/usr/bin/bash

_test_awk_bt_line_old_dir=$PWD
root_dir="${_test_awk_bt_line_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./awk/awk_bt_line.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_awk_bt_line_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local tmp_file=$(mktemp)
    local test_str
    local test_str_after
    local get_str

    {
    IFS= read -r -d '' test_str <<'    EOF'
test1
xx
yy
oo
  
xx
yy
kk
  
test2
d12
d22

mm
kk
dd
dd
13434k
  
test3
gge
ggge
    EOF
    } || true

    {
    IFS= read -r -d '' test_str_after <<'    EOF'
test1
xx
yy
oo
test2
d12
d22
test3
gge
    EOF
    } || true
    test_str_after+='ggge'

    get_str=$(echo "$test_str" | awk_bt_line 'test' '^[ \t]*$')
    
    if [[ "$get_str" == "$test_str_after" ]] ; then
        echo "${FUNCNAME[0]} test pass."
    else
        echo "${FUNCNAME[0]} test fail."
    fi
    


}

test_case1

