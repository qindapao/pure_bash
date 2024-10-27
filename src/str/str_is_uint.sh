. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_uint]++)) && return 0

str_is_uint ()
{
    # 这个函数认可10进制前的前导0
    [[ "$1" =~ ^0[xX][0-9A-Fa-f]+$ ]] || [[ "$1" =~ ^[0-9]+$ ]]
}

return 0

