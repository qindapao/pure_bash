. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_decimal]++)) && return 0

# 前导0认为合法
str_is_decimal () { [[ "${1}" =~ ^[-+]?[0-9]+$ ]] ; }

return 0

