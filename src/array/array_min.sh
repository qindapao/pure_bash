. ./meta/meta.sh
((DEFENSE_VARIABLES[array_min]++)) && return 0


# 非引用传递函数
# 求数组中按照数字排序最小的元素
# @: 整个数组的参数
array_min ()
{
    local min_var=$1
    shift
    local i
    for i in "${@}" ; do
        ((min_var=(i<min_var)?i:min_var))
    done
    printf "%s" "$min_var"
}

return 0

