. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_set_params_del_bracket]++)) && return 0

# 删除参数数组中的左右中括号
struct_set_params_del_bracket ()
{
    local -n _struct_set_params_del_bracket_params_array_ref="${1}"
    local _struct_set_params_del_bracket_index
    local _struct_set_params_del_bracket_tmp_var

    for _struct_set_params_del_bracket_index in "${!_struct_set_params_del_bracket_params_array_ref[@]}" ; do
        _struct_set_params_del_bracket_tmp_var="${_struct_set_params_del_bracket_params_array_ref["$_struct_set_params_del_bracket_index"]}"
        _struct_set_params_del_bracket_tmp_var=${_struct_set_params_del_bracket_tmp_var#[}
        _struct_set_params_del_bracket_params_array_ref["$_struct_set_params_del_bracket_index"]=${_struct_set_params_del_bracket_tmp_var%]}
    done
}

return 0

