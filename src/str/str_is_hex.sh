. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_hex]++)) && return 0

# 前导0认为合法
str_is_hex () { [[ "${2}" =~ ^[-+]?0[xX][0-9A-Fa-f]+$ ]] ; }

alias str_is_hex_s='str_is_hex ""'

return 0

