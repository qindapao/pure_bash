. ./meta/meta.sh
((DEFENSE_VARIABLES[json_set_params_del_bracket]++)) && return 0

# 删除参数数组中的左右中括号
json_set_params_del_bracket ()
{
    local -n _json_set_params_del_bracket_params_array_ref=$1
    local _json_set_params_del_bracket_{index,tmp_var}

    for _json_set_params_del_bracket_index in "${!_json_set_params_del_bracket_params_array_ref[@]}" ; do
        _json_set_params_del_bracket_tmp_var="${_json_set_params_del_bracket_params_array_ref["$_json_set_params_del_bracket_index"]}"
        _json_set_params_del_bracket_tmp_var=${_json_set_params_del_bracket_tmp_var#[}
        _json_set_params_del_bracket_params_array_ref["$_json_set_params_del_bracket_index"]=${_json_set_params_del_bracket_tmp_var%]}
    done
}

return 0

