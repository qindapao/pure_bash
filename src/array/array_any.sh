. ./meta/meta.sh
((DEFENSE_VARIABLES[array_any]++)) && return 0


# 只要数组中的元素有一个能满足给定函数的要求，就返回真，否则返回假
# 需要给函数传递一个函数引用
# 1: 需要操作的数组的名字
# 2: 函数名
# @: 其它参数
# $: 当前迭代数据索引
#
# 空数组返回假(没有元素满足条件)
# (函数的这种行为是基于逻辑和数学中的约定，
# 特别是在处理空集合时的全称量化和存在量化的原则。)
array_any ()
{
    local -n _array_any_ref_arr=$1
    # 如果别名未定义就是第二个参数(:- 表示未定义或者为空 -表示为定义)
    # local _array_any_function=${BASH_ALIASES[$2]-$2}
    local _array_any_function=$2
    shift 2

    local _array_any_index
    for _array_any_index in "${!_array_any_ref_arr[@]}" ; do
        if eval ${_array_any_function} '"$_array_any_index"' '"${_array_any_ref_arr[$_array_any_index]}"' '"${@}"' ; then
            return 0
        fi
    done

    return 1
}

return 0

