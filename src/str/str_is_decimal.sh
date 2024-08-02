. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_decimal]++)) && return 0

# 前导0认为合法
str_is_decimal () { [[ "${2}" =~ ^[-+]?[0-9]+$ ]] ; }

alias str_is_decimal_s='str_is_decimal ""'

return 0

