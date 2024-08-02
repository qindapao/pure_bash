. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_uint]++)) && return 0

str_is_uint ()
{
    # 这个函数认可10进制前的前导0
    [[ "$2" =~ ^0[xX][0-9A-Fa-f]+$ ]] || [[ "$2" =~ ^[0-9]+$ ]]
}

alias str_is_uint_s='str_is_uint ""'

return 0

