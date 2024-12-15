. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_func_updict]++)) && return 0

. ./dict/dict_by_kv.sh || return 1
. ./str/str_q_to_arr.sh || return 1

# 1: 函数名
# 2: 传出变量名
# 3~n: 函数传出参数
atom_func_updict () 
{
    local REPLY=''
    if [[ "${BASH_ALIASES[$2]:+set}" ]] ; then
        local alias_arr_$1
        str_q_to_arr alias_arr_$1 "${BASH_ALIASES[$2]}"

        eval '"${alias_arr_'$1'[@]}" "${@:3}"'
    else
        ${2} "${@:3}"
    fi
    set -- "$1" "$?"
    eval "local kv_$1=($REPLY)"
    # 高等级的bash可以使用更简洁的语法
    # declare -A dict=(a b c d) 等效于
    # declare -A dict=([a]=b [c]=d)
    dict_by_kv $1 kv_$1
    return $2
}

return 0

