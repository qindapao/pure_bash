. ./meta/meta.sh
((DEFENSE_VARIABLES[float_compare]++)) && return 0

# 返回值
# 0: $1>$2
# 1: $1=$2
# 2: $1<$2
float_compare () { return $(awk '{ print('$1'>'$2'?0:'$1'=='$2'?1:2) }' <<<'') ; }

return 0

