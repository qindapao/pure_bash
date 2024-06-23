. ./meta/meta.sh
((DEFENSE_VARIABLES[array_all]++)) && return 0


# 数组中所有元素都满足要求,返回 真,否则返回假
# 空数组返回真(没有元素违反条件)
# (函数的这种行为是基于逻辑和数学中的约定，
# 特别是在处理空集合时的全称量化和存在量化的原则。)
array_all ()
{
    local -n _array_all_ref_arr="${1}"
    local _array_all_function="${2}"
    shift 2

    local _array_all_index
    for _array_all_index in "${!_array_all_ref_arr[@]}" ; do
        if ! "$_array_all_function" "${_array_all_ref_arr["$_array_all_index"]}" "$_array_all_index" "${@}" ; then
            return 1
        fi
    done

    return 0
}

return 0

