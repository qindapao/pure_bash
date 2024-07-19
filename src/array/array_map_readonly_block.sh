. ./meta/meta.sh
((DEFENSE_VARIABLES[array_map_readonly_block]++)) && return 0

# 执行匿名代码块不改变原始数组
# :TODO: 待测试,block临时函数中包含别名的情况
array_map_readonly_block ()
{
    local -n array_map_readonly_block_ref_arr=$1
    local array_map_readonly_block_exec_block=$2 
    
    eval "array_map_readonly_block_tmp_function() { "$array_map_readonly_block_exec_block" ; }"
    local array_map_readonly_block_index

    for array_map_readonly_block_index in "${!array_map_readonly_block_ref_arr[@]}" ; do
        array_map_readonly_block_tmp_function "$array_map_readonly_block_index" "${array_map_readonly_block_ref_arr[$array_map_readonly_block_index]}"
    done

    unset -f array_map_readonly_block_tmp_function
}

return 0

