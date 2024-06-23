. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_decimal_num]++)) && return 0

str_is_decimal_num ()
{
    [[ "${1}" =~ ^[1-9][0-9]*$|^0$ ]]
}

return 0

