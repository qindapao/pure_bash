. ./meta/meta.sh
((DEFENSE_VARIABLES[array_max]++)) && return 0

# 非引用传递函数
# 求数组中按照数字排序最大的元素
# @: 整个数组的参数
array_max ()
{
    local max_var=$1
    shift
    local i
    for i in "${@}" ; do
        ((max_var=(i>max_var)?i:max_var))
    done
    printf "%s" "$max_var"
}

return 0

