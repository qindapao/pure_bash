. ./meta/meta.sh
((DEFENSE_VARIABLES[array_map_readonly]++)) && return 0

# 对映射的每个数组元素进行操作,但是不改变原数组
array_map_readonly ()
{
    local -n array_map_readonly_ref_arr=$1
    # local array_map_readonly_function=${BASH_ALIASES[$2]-$2}
    local array_map_readonly_function=$2
    shift 2
    local array_map_readonly_function_params=("${@}")
    local array_map_readonly_index
    for array_map_readonly_index in "${!array_map_readonly_ref_arr[@]}" ; do
        eval ${array_map_readonly_function} '"$array_map_readonly_index"' '"${array_map_readonly_ref_arr[$array_map_readonly_index]}"' '"${array_map_readonly_function_params[@]}"'
    done
}

return 0

