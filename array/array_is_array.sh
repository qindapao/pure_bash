. ./meta/meta.sh
((DEFENSE_VARIABLES[array_is_array]++)) && return 0

. ./atom/atom_identify_data_type.sh || return 1

# 判断一个数据结构是否是一个数组(不管是否是引用都能正确处理)
# 1: 需要判断的数组的名字
array_is_array ()
{
    atom_identify_data_type "${1}" "a" && return 0 || return 1
}

return 0

