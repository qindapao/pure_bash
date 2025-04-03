#!/usr/bin/bash

_test_awk_add_separator_old_dir=$PWD
root_dir="${_test_awk_add_separator_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./awk/awk_add_separator.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_awk_add_separator_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

test_case1 ()
{
    local tmp_file=$(mktemp)
    local test_str=
    {
    IFS= read -r -d '' test_str <<'EOF'
this is test start
abc
123
this is test end
this is test start
&^%^
不对的
this is test end
EOF
} || true

    printf "%s" "$test_str" >"$tmp_file"

    local get_str=$(awk_add_separator 'this is test start' 'this is test end' '-----' "$tmp_file")
    local spec_str=
    {
    IFS= read -r -d '' spec_str <<'EOF'
this is test start
abc
123
-----
this is test start
&^%^
不对的
-----
EOF
} || true

    rm -f "$tmp_file"
    
    # $()结构会去掉结尾的换行符
    get_str+=$'\n'

    if [[ "$get_str" == "$spec_str" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local test_str=
    {
    IFS= read -r -d '' test_str <<'EOF'
this is test start
abc
123
this is test end
this is test start
&^%^
不对的
this is test end
EOF
} || true

    local get_str=$(echo "$test_str" | awk_add_separator 'this is test start' 'this is test end' '-----')
    local spec_str=
    {
    IFS= read -r -d '' spec_str <<'EOF'
this is test start
abc
123
-----
this is test start
&^%^
不对的
-----
EOF
} || true

    # $()结构会去掉结尾的换行符
    get_str+=$'\n'

    if [[ "$get_str" == "$spec_str" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case2

