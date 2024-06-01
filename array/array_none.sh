. ./meta/meta.sh
((DEFENSE_VARIABLES[array_none]++)) && return 0


# 如果数组中的每个元素都不满足条件,返回 真 ,否则返回假
# 空数组返回真(没有元素违反条件)
# (函数的这种行为是基于逻辑和数学中的约定，
# 特别是在处理空集合时的全称量化和存在量化的原则。)
array_none ()
{
    local -n _array_none_ref_arr="${1}"
    local _array_none_function="${2}"
    shift 2

    local _array_none_index
    for _array_none_index in "${!_array_none_ref_arr[@]}" ; do
        if "$_array_none_function" "${_array_none_ref_arr["$_array_none_index"]}" "$_array_none_index" "${@}" ; then
            return 1
        fi
    done

    return 0
}

return 0

