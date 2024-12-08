. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_func_upstr]++)) && return 0

# 1: 函数名
# 2: 传出变量名
# 3~n: 函数传出参数
atom_func_upstr () 
{
    local REPLY=''
    if [[ "${BASH_ALIASES[$2]:+set}" ]] ; then
        local alias_arr_$1
        if [[ -o noglob ]] ; then
            eval 'alias_arr_'$1'=('${BASH_ALIASES[$2]}')'
        else
            local - ; set -f ; eval 'alias_arr_'$1'=('${BASH_ALIASES[$2]}')' ; set +f
        fi
        eval '"${alias_arr_'$1'[@]}" "${@:3}"'
    else
        ${2} "${@:3}"
    fi
    set -- "$1" "$?"
    eval $1='${REPLY}'
    return $2
}

return 0

