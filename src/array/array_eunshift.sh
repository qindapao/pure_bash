. ./meta/meta.sh
((DEFENSE_VARIABLES[array_eunshift]++)) && return 0

# 使用evil的原生unshift,拥有最高效率
# bash4.0或者以上,致密数组
array_eunshift () { eval -- "$1=(\"\${@:2}\" \"\${$1[@]}\")" ; }
return 0

