. ./meta/meta.sh
((DEFENSE_VARIABLES[set_add]++)) && return 0

# 集合中增加一个元素,x的作用是防止空键
# :TODO: 字典是否需要做防止空键的防呆处理?
set_add () { eval -- "$1[x\$2]=1" ; }

return 0

