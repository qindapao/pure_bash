. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_decimal_num]++)) && return 0

str_is_decimal_num () { [[ "${2}" =~ ^[1-9][0-9]*$|^0$ ]] ; }

alias str_is_decimal_num_s='str_is_decimal_num ""'

return 0

