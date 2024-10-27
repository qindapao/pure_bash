#!/usr/bin/bash

_test_str_del_xml_ill_char_old_dir="$PWD"
root_dir="${PWD%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1
. ./str/str_del_xml_ill_char.sh || return 1
. ./cntr/cntr_map.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_str_del_xml_ill_char_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# set -vx
test_case1 ()
{
    local str='age&<>&&&<>12334'
    str_del_xml_ill_char str
    if [[ "$str" == 'age12334' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case2 ()
{
    local str='a223&geg&<geg>gge1233'
    local str_after=$(echo "$str" | str_del_xml_ill_char)
    if [[ $str_after == 'a223geggeggge1233' ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case3 ()
{
    local array=('a223&geg&<geg>gge1233' '&&<>' '1222&<>>>>')
    local array_after=('a223geggeggge1233' '' '1222')
    cntr_map array str_del_xml_ill_char
    if assert_array 'a' array array_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case4 ()
{
    local -A dict=([my]='a223&geg&<geg>gge1233' [my2]='&&<>' [789x]='1222&<>>>>')
    local -A dict_after=([my]='a223geggeggge1233' [my2]='' [789x]='1222')

    cntr_map dict str_del_xml_ill_char
    if assert_array 'A' dict dict_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}

test_case1 &&
test_case2 &&
test_case3 &&
test_case4

