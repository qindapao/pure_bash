. ./meta/meta.sh
((DEFENSE_VARIABLES[json_cp]++)) && return 0

# 结构体拷贝,其实就是数组的拷贝或者关联数组的拷贝
json_cp ()
{
    local -n _json_cp_{old="$1",new="$2"}
    local _json_cp_index

    _json_cp_new=()

    for _json_cp_index in "${!_json_cp_old[@]}" ; do
        _json_cp_new[${_json_cp_index}]="${_json_cp_old[$_json_cp_index]}"
    done
}

return 0

