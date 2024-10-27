. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_hex]++)) && return 0

# 前导0认为合法
str_is_hex () { [[ "${1}" =~ ^[-+]?0[xX][0-9A-Fa-f]+$ ]] ; }

return 0

