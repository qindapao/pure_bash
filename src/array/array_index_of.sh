. ./meta/meta.sh
((DEFENSE_VARIABLES[array_index_of]++)) && return 0

# 获取某个元素的首索引
# 1: 数组的引用名字
# 2: 传出的索引号(如果失败,置为-1)变量名
# 3: 查找的元素名
array_index_of ()
{
    local script_$1$2='
        '$2'=-1
        local eAI=$3
        local -i iAI
        for iAI in "${!'$1'[@]}" ; do
            [[ "${'$1'[iAI]}" == "$eAI" ]] && {
                '$2'=$iAI
                break
            }
        done
        (('$2'!=-1))
    '
    eval -- eval -- '"${script_'$1$2'//AI/$1$2}"'
}

return 0

