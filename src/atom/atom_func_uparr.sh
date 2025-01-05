. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_func_uparr]++)) && return 0

. ./str/str_q_to_arr.sh || return 1

# 1: 传出变量名
# 2: 函数名
# 3~n: 函数传出参数
# REPLY 保存Q字符串中间用空格分隔便于还原数组(不支持稀疏数组特性了)
atom_func_uparr () 
{
    local REPLY=''
    if [[ "${BASH_ALIASES[$2]:+set}" ]] ; then
        local -a "alias_arr_$1=()"
        str_q_to_arr alias_arr_$1 "${BASH_ALIASES[$2]}"
        eval '"${alias_arr_'$1'[@]}" "${@:3}"'
    else
        ${2} "${@:3}"
    fi
    set -- "$1" "$?"
    eval "$1=($REPLY)"
    return $2
}

return 0

