. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_grep_block]++)) && return 0

# 使用匿名代码块来进行过滤
dict_grep_block ()
{
    local -n _dict_grep_block_ref_dict="${1}" _dict_grep_block_out_dict="${2}"
    _dict_grep_block_out_dict=()
    local _dict_grep_block_exec_block="${3}"

    eval "_dict_grep_block_tmp_function() { "$_dict_grep_block_exec_block" ; }"
    local _dict_grep_block_index

    for _dict_grep_block_index in "${!_dict_grep_block_ref_dict[@]}" ; do
        if _dict_grep_block_tmp_function "${_dict_grep_block_ref_dict["$_dict_grep_block_index"]}" "$_dict_grep_block_index" ; then
            _dict_grep_block_out_dict["$_dict_grep_block_index"]="${_dict_grep_block_ref_dict["$_dict_grep_block_index"]}"
        fi
    done

    unset -f _dict_grep_block_tmp_function

    ((${#_dict_grep_ref_out_arr[@]})) && return 0 || return 1
}

return 0

