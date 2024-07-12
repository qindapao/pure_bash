. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_equa]++)) && return 0

# 判断两个字符串相等($1保留为高阶数组中的索引)
str_is_equa () { [[ "$2" == "$3" ]] ; }

alias str_is_equa_s='str_is_equa ""'

return 0

