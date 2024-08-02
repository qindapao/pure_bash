. ./meta/meta.sh
((DEFENSE_VARIABLES[array_same_item]++)) && return 0


# :TODO: 这个函数实现效率并不高
# 往一个数组中填充指定数量相同元素
# 1: 需要填充的数组
# 2: 每个数组元素的字符(不能有空格)
# 3: 填充元素个数
array_same_item () { eval "$1=(\$(printf \"%0.s${2}\n\" {1..${3}}))" ; }

return 0

