. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_black_or_empty]++)) && return 0

# 可以用于cntr_grep
# 判断一个字符串是否只包含空白字符或者是空字符串
# 传参数量
# 1:
#   字符串值
str_is_black_or_empty () { set -- "${1//[[:space:]]/}" ; [[ -z "$1" ]] ; }

return 0

