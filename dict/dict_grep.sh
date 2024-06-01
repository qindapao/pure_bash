. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_grep]++)) && return 0

# 字典grep,如果有元素查找到,返回真,否则返回假
# 不改变原始的字典
dict_grep ()
{
    local -n _dict_grep_ref_dict="${1}" _dict_grep_ref_out_dict="${2}"
    _dict_grep_ref_out_dict=()
    local _dict_grep_function="${3}"
    shift 3
    local -a _dict_grep_params=("${@}")
    local _dict_grep_i
    
    for _dict_grep_i in "${!_dict_grep_ref_dict[@]}" ; do
        if "$_dict_grep_function" "${_dict_grep_ref_dict["$_dict_grep_i"]}" "$_dict_grep_i" "${_dict_grep_params[@]}"  ; then
            _dict_grep_ref_out_dict["$_dict_grep_i"]="${_dict_grep_ref_dict["$_dict_grep_i"]}"
        fi
    done
    
    ((${#_dict_grep_ref_out_dict[@]})) && return 0 || return 1
}

return 0

