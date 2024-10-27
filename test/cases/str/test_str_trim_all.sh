#!/usr/bin/bash

_test_str_trim_all_old_dir="$PWD"
root_dir="${_test_str_trim_all_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_trim_all.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_trim_all_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -xv

test_case1 ()
{
    local ret1 ret2
    local a=' ggge gg        geg         gee        '
    local a_after='ggge gg geg gee'

    str_trim_all a
    [[ "$a" == "$a_after" ]]
    ret1=$?
    local array=('1' '  ge     ge  gge       ')
    local array_after=('1' 'ge ge gge')
    str_trim_all array 1 "${array[1]}"
    assert_array 'a' array array_after
    ret2=$?
    if ((ret1|ret2)) ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    else
        echo "${FUNCNAME[0]} test pass."
        return 0
    fi
}

test_case2 ()
{
    local -A dict=(['gge
    gge(]']='  ggeeg    geg gg')
    local -A dict_after=(['gge
    gge(]']='ggeeg geg gg')
    str_trim_all dict 'gge
    gge(]' '  ggeeg    geg gg'

    if assert_array 'A' dict dict_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case3 ()
{
    local str='       g g          gge 223 xx       xyy   '
    local str_after='g g gge 223 xx xyy'
    local str_conv=$(printf "%s" "$str" | str_trim_all)
    if [[ "$str_after" == "$str_conv" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}


ret=0
test_case1
((ret|=$?))
test_case2
((ret|=$?))
test_case3
((ret|=$?))

exit $ret

