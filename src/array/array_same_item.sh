. ./meta/meta.sh
((DEFENSE_VARIABLES[array_same_item]++)) && return 0

# 往一个数组中填充指定数量相同元素
# 1: 需要填充的数组
# 2: 每个数组元素的字符(不能有空格)
# 3: 填充元素个数
array_same_item ()
{
    eval -- '
        '$1'=()
        local -i index_'$1'
        for ((index_'$1'=0;index_'$1'<$3;index_'$1'++)) ; do
            '$1'[index_'$1']=$2
        done
    '
}

return 0

