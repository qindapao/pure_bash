#!/usr/bin/bash

_test_printf_old_dir="$PWD"
root_dir="${_test_printf_old_dir%%/pure_bash*}/pure_bash"

cd "$root_dir"/src
. ./log/log_dbg.sh || return 1
. ./date/date_log.sh || return 1

cd "$root_dir"/test/lib
. ./assert/assert_array.sh || return 1

cd "$_test_printf_old_dir"

# 打印用例开始执行
echo "=========${0} test start in $(date_log)=========="

# echo 后面打印的内容如果为选项,会打印不出来
a='-e'
echo "$a"
# 上面打印出来是空
# 加了--也不行,会把 -- -e一起打印出来
echo -- "$a"
# -- -e

# printf 如果直接打印，遇到选项也打印不出来
a='-v'
printf "$a"
# 这会导致下面的错误打印
# -bash: printf: -v: option requires an argument
# printf: usage: printf [-v var] format [arguments]

# 但是如果加了--就可以正常打印
printf -- "$a"
# 这样任何情况都能打印
printf "%s" "$a"

test_case1 ()
{
    local -A dict
    dict['xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)
geg']=' xy'
    local i='xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)
geg'
    local j=dict

    local -A dict_after
    dict_after['xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)
geg']=' 4 56'

    if ((__META_BASH_VERSION>=5000000)) ; then
        if shopt -q assoc_expand_once ; then
            printf -v "$j[$i]" "%s" ' 4 56'
        else
            shopt -s assoc_expand_once
            printf -v "$j[$i]" "%s" ' 4 56'
            shopt -u assoc_expand_once
        fi
    else
        eval -- ''$j'[$i]="4 56"'
    fi

    declare -p dict dict_after

    if assert_array 'A' dict dict_after ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi
}
test_case1

