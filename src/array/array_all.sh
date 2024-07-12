. ./meta/meta.sh
((DEFENSE_VARIABLES[array_all]++)) && return 0


# 数组中所有元素都满足要求,返回 真,否则返回假
# 空数组返回真(没有元素违反条件)
# (函数的这种行为是基于逻辑和数学中的约定，
# 特别是在处理空集合时的全称量化和存在量化的原则。)
# 子函数第一个参数为数组索引
#       第二个参数为数组值
#
#  :TODO: 以后关于函数的限制说明之类的东西全部写到模块相关的todo中去!
#  把模块TODO写成一个MD文档而不是一个.sh文件
array_all ()
{
    local -n _array_all_ref_arr=$1
    # local _array_all_function=${BASH_ALIASES[$2]-$2}
    # 不管是函数还是别名,用eval都只能直接执行
    local _array_all_function=$2
    shift 2

    local _array_all_index
    for _array_all_index in "${!_array_all_ref_arr[@]}" ; do
        # 双引号外面包裹一层单引号
        if ! eval ${_array_all_function} '"$_array_all_index"' '"${_array_all_ref_arr[$_array_all_index]}"' '"${@}"' ; then
            return 1
        fi
    done

    return 0
}

return 0

