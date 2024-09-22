. ./meta/meta.sh
((DEFENSE_VARIABLES[array_egenerator]++)) && return 0

# 生成一个数组
# :TODO: 标头不能包含空格,比如下面的POWER不能包含空格
# array_egenerator my_array POWER 1 8
array_egenerator () { eval -- "$1=($2{$3..$4})" ; }
return 0

