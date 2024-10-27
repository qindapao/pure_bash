. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_strict_decimal]++)) && return 0

# 前导0认为不合法
str_is_strict_decimal () { [[ "${1}" =~ ^[-+]?[1-9][0-9]*$|^0$ ]] ; }

return 0

