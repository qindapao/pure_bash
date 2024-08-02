. ./meta/meta.sh
((DEFENSE_VARIABLES[array_same_sitem]++)) && return 0


# :TODO: 这个函数实现效率并不高
# 往一个数组中填充指定数量相同元素
# 1: 需要填充的数组
# 2: 每个数组元素的字符(不能有空格)
# 3: 填充元素个数
array_same_sitem () 
{ 
    echo "${001}"
    echo "${002}"
    # 这里依然是有BUG的
    # cnt="4" x="A B"
    eval -- "eval -- 'eval -- a[\\\${#a[@]}]=\\\"\\\$\\{{${cnt}1..$cnt$cnt}-\\\"\\\$x\\\"\\}\\\"'"

    return 0
}

return 0

