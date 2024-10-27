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


test_key_v ()
{
    cnt="xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"
    declare -A tmp_key=(["xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"]="xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)" [0]="xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)" )
    declare -A k=(["xxx xxx->xxx->xxx->xx:xx.x-/dev/fd/61-/dev/fd/60"]="1" ["xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"]="2" ["xxx->xxx->xxx->xx:xx.x-/dev/fd/61-/dev/fd/60"]="1" ["(xx:yy)"]="6" [5]="4" )
    # # 验证发现只有bash5.2下面可以用双引号包裹,其它版本都不行
    # if [[ -v 'k[${tmp_key[$cnt]}]' ]] ; then echo xx; fi
    # # 验证发现只有bash5.2可以处理unset中的多级嵌套,其它版本都最好用一个中间变量
    # unset 'k[${tmp_key[$cnt]}]'
    # # 下面这个语法是危险的
    # if [[ -v 'k[${tmp_key[$cnt]}]' ]] ; then echo xx; fi

    xx="${tmp_key[$cnt]}"
    unset 'k[$xx]'
    if (($?)) ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    else
        echo "${FUNCNAME[0]} test pass."
        return 0
    fi
}

test_key_v

