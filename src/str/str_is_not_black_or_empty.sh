. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_not_black_or_empty]++)) && return 0

# 可以用于cntr_grep
# 判断一个字符串是否包含有效字符
# 传参数量
# 1:
#   字符串值
str_is_not_black_or_empty () { set -- "${1//[[:space:]]/}" ; [[ -n "$1" ]] ; }

return 0

