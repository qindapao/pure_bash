 . ./meta/meta.sh
((DEFENSE_VARIABLES[array_epush]++)) && return 0

# 使用evil的原生push,和直接操作拥有同样的效率
# bash4.0或者以上,致密数组
array_epush () { eval "$1+=(\"\${@:2}\")" ; }
return 0

