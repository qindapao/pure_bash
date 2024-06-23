. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_not_equa]++)) && return 0

# 判断两个字符串不相等($2保留为高阶数组中的索引)
str_is_not_equa () { [[ "$3" != "$1" ]] ; }

return 0

