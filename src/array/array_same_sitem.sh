. ./meta/meta.sh
((DEFENSE_VARIABLES[array_same_sitem]++)) && return 0


# 效率比array_same_item差多了
# 尽量不要使用这个函数,这里只是为了暂时某种可能的实现
# 往一个数组中填充指定数量相同元素
# 1: 需要填充的数组
# 2: 需要填充的数据内容
# 3: 填充元素个数
array_same_sitem () 
{ 
    local s_index
    printf -v s_index "%0${#3}d" "1"
    # ${3}${s_index}..${3}${3} 改成 4${s_index}..4${3}
    # 因为参数只有3个,所以这里的参数一定是未设定状态
    eval -- "eval -- 'eval -- '$1'[\\\${#'$1'[@]}]=\\\"\\\$\\{{${3}${s_index}..${3}${3}}-\\\"\\\$2\\\"\\}\\\"'"

    return 0
}

# 只支持不含空格元素的简洁版本(效率并不高,没必要使用)
# array_same_item () { eval "$1=(\$(printf \"%0.s${2}\n\" {1..${3}}))" ; }

return 0

