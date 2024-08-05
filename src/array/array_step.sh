. ./meta/meta.sh
((DEFENSE_VARIABLES[array_step]++)) && return 0

# 实现数组的步进(生成一个子步进数组)
# 1: 原数组
# 2: 获取步进后的数组
# 3: 步进开始索引
# 4: 步进值
array_step ()
{
    eval -- '
        local _iter_'$1$2'
        for ((_iter_'$1$2'=$3;_iter_'$1$2'<${#'$1'[@]};_iter_'$1$2'+=$4)) ; do
            '$2'+=("${'$1'[_iter_'$1$2']}")
        done
    '
    return 0
}

return 0

