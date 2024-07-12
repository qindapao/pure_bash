. ./meta/meta.sh
((DEFENSE_VARIABLES[array_todo]++)) && return 0

# :TODO: 一种利用参数扩展连续给数组赋值的方法,不知道有什么用
# let 'a['{1..4}']=2'
# eval let 'a['{1.."$x"}']=2'
# eval "declare -a a[{1..$x}]=xxxgege"

# :TODO: 数组是否需要实现集合的4种操作?

# :TODO: 这里有个参考库,https://cfajohnson.com/shell/arrays/
# 并不是所有的函数都有价值实现,可以先保存

return 0

