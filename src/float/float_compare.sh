. ./meta/meta.sh
((DEFENSE_VARIABLES[float_compare]++)) && return 0

# 返回值
# 0: $1>$2
# 1: $1=$2
# 2: $1<$2
# 这里的BEGIN是必须的,它在任何输入行之前执行,不然就会等待输入
# 这里的awk命令的退出码就是函数的退出码
float_compare () { awk 'BEGIN {exit ('$1'>'$2'?0:('$1'=='$2'?1:2))}' ; }

return 0

