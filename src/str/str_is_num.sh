. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_num]++)) && return 0

str_is_num ()
{
    # :TODO: 这里的10进制数没有考虑前面有0的数字,可能比较危险
    [[ $1 =~ ^0[xX][0-9A-Fa-f]+$ ]] || [[ $1 =~ ^[0-9]+$ ]]
}

return 0

