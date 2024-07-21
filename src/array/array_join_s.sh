. ./meta/meta.sh
((DEFENSE_VARIABLES[array_join_s]++)) && return 0

# 把数组链接成字符串(单一字符分隔符)
# 1: 分隔符
# 2: 数组列表
array_join_s () { local IFS=$1 ; shift ; printf "%s" "${*}" ; }

return 0

