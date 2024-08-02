. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_strict_decimal]++)) && return 0

# 前导0认为不合法
str_is_strict_decimal () { [[ "${2}" =~ ^[-+]?[1-9][0-9]*$|^0$ ]] ; }

alias str_is_strict_decimal_s='str_is_strict_decimal ""'

return 0

