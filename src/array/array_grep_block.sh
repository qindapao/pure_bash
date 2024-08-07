. ./meta/meta.sh
((DEFENSE_VARIABLES[array_grep_block]++)) && return 0

# 使用匿名代码块来进行过滤
# :TODO: 待测试,如果block函数中有别名会怎么样?
array_grep_block ()
{
    # 这种情况下双引号就是必不可少的了
    local -n _array_grep_block_{ref_arr="$1",out_arr="$2"}
    _array_grep_block_out_arr=()
    local _array_grep_block_exec_block=$3

    eval "_array_grep_block_tmp_function() { "$_array_grep_block_exec_block" ; }"
    local _array_grep_block_index

    for _array_grep_block_index in "${!_array_grep_block_ref_arr[@]}" ; do
        if _array_grep_block_tmp_function "$_array_grep_block_index" "${_array_grep_block_ref_arr[$_array_grep_block_index]}" ; then
            _array_grep_block_out_arr[$_array_grep_block_index]="${_array_grep_block_ref_arr[$_array_grep_block_index]}"
        fi
    done

    unset -f _array_grep_block_tmp_function

    if((${#_array_grep_ref_out_arr[@]})) ; then
        _array_grep_block_out_arr=("${_array_grep_block_out_arr[@]}")
        return 0
    fi
    return 1
}

return 0

