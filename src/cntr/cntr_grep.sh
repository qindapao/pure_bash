. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_grep]++)) && return 0

. ./cntr/cntr_copy.sh || return 1
. ./cntr/cntr_common.sh || return 1
. ./array/array_last_i.sh || return 1

# 处理后的数组是置密的,筛选函数只接受一个参数就是数组元素值
# 同时支持过滤条件是函数/别名/代码块
# 1: 需要过滤的数组名
# 2: 过滤条件(函数/别名/代码块)
#       如果是代码块,那么必须包含$1或者$2或者$3,比如
#       '[[ "${1}" == "3 3" ]]'
#       过滤函数可以得到三个参数
#       值 键 变量名
# 3: 函数功能
#            : 过滤功能(无参数默认为0)
#    any    : any 功能,只要有一个满足条件就退出,返回真(空容器返回假)
#    all    : all 功能,所有满足条件才返回真,只要有一个不满足条件都返回假(空容器返回真)
#   none    : none 功能,所有都不满足条件才返回真,只要有一个满足条件都返回假(空容器返回真)
#   first_k : 返回满足添加的第一个索引值(对关联数组无意义)
#   first_v : 返回满足条件的第一个值(对关联数组无意义)
#   last_k  : 返回满足条件的最后一个索引值(对关联数组无意义)
#   last_v  : 返回满足条件的最后一个值(对关联数组无意义)
#
#   (对于空容器的这种行为是基于逻辑和数学中的约定，
#   特别是在处理空集合时的全称量化和存在量化的原则。)

# 返回值: 
#   0: 过滤有发生(最终数组中有元素)
#   1: 过滤没有发生(最终数组中没有元素)
#
# 子函数/别名/代码块参数说明
#   1: 数组元素值
#   2: 数组索引值
#   3: 数组变量名称
#
# 特殊效果:
#   在子函数中除了进行条件判断外,在满足条件的情况下甚至可以改变传入的数组的元素的
#   值,但是一般不建议这样用,可读性不好,可以和map函数搭配使用
#
#   :TODO: 函数在某些条件下没有删除临时函数,其实没有关系,重新进来会覆盖掉
#   :TODO: last_k的时候其实翻转数组然后再判断可能效率更高,只是和当前代码框架不兼容
#          所以不去实现
#   注意: 在eval的代码模板生成的最终字符串中最多只能进行一次替换,
#         再进行一次替换无法预知已经替换后的字符串中是否包含下次要替换
#         的字符串,会有风险!
cntr_grep ()
{
    local _cntr_grep_script$1$4="${CNTR_TEMPLATE_CHEKC_TYPE//NAME/$1$4}"
    local _cntr_grep_script$1$4+="${CNTR_TEMPLATE_GENERATE_TEMP_FUNC_BEFORE//NAME/$1$4}"
    local _cntr_grep_script$1$4+="$2"
    local _cntr_grep_script$1$4+="${CNTR_TEMPLATE_GENERATE_TEMP_FUNC_AFTER//NAME/$1$4}"
    
    local _cntr_grep_script$1$4+='
    local i'$1$4' filter_ret'$1$4'=1
    for i'$1$4' in "${!'$1'[@]}" ; do
        if eval "$2" '\''"${'$1'[$i'$1$4']}"'\'' '\''"$i'$1$4'"'\'' '\'''$1''\'' ; then
            case "$3" in
            any) return 0 ;;
            none) return 1 ;;
            first_k)    '$4'="$i'$1$4'" ; return 0 ;;
            first_v)    '$4'="${'$1'[$i'$1$4']}" ; return 0 ;;
            *) a'$1$4'[$i'$1$4']="${'$1'[$i'$1$4']}" ; filter_ret'$1$4'=0 ;;
            esac
        else
            case "$3" in
            all)  return 1 ;;
            esac
        fi
    done
    '
    local _cntr_grep_script$1$4+="${CNTR_TEMPLATE_DEL_TEMP_FUNC//NAME/$1$4}"
    local _cntr_grep_script$1$4+='
    case "$3" in
    any|first_[kv])  return 1 ;;
    all|none)  return 0 ;;
    # 特别处理下last_k last_v
    last_[kv])
        if ((${#a'$1$4'[@]})) ; then
            case "$3" in
            last_k) array_last_i a'$1$4' '$4' ;;
            last_v) '$4'=${a'$1$4'[-1]} ;;
            esac
            return 0
        else
            return 1
        fi
        ;;
    esac


    ((a_type'$1$4')) && cntr_copy '$1' a'$1$4' || '$1'=("${a'$1$4'[@]}")
    return $filter_ret'$1$4'
    '
    eval -- eval -- '"${_cntr_grep_script'$1$4'}"'
}

return 0

