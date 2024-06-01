. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_num]++)) && return 0

str_is_num ()
{
    if [[ $1 =~ ^0[xX][0-9A-Fa-f]+$ ]] || [[ $1 =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

return 0

