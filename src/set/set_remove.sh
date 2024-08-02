. ./meta/meta.sh
((DEFENSE_VARIABLES[set_remove]++)) && return 0

# 集合中删除一个元素,x的作用是防止空键
set_remove () { unset -v ''$1'[x$2]' ; }

return 0

