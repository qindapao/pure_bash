. ./meta/meta.sh
((DEFENSE_VARIABLES[array_map_block]++)) && return 0

# 执行一个匿名函数
# $ array_map_block a "$(cat <<-'EOF'
# local x=$1 ;
# printf "%s" $((x+1)) ;
# EOF  
# )" 
#
# 1: 需要迭代操作的数据引用
# 2: 执行的匿名代码块
array_map_block ()
{
    local -n _array_map_block_ref_arr="${1}"
    local _array_map_block_exec_block="${2}" 
    
    eval "_array_map_block_tmp_function() { "$_array_map_block_exec_block" ; }"
    local _array_map_block_index

    for _array_map_block_index in "${!_array_map_block_ref_arr[@]}" ; do
        _array_map_block_ref_arr[$_array_map_block_index]=$(_array_map_block_tmp_function "${_array_map_block_ref_arr["$_array_map_block_index"]}" "$_array_map_block_index")
    done

    unset -f _array_map_block_tmp_function
}

return 0

