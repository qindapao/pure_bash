. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_uniq]++)) && return 0

# 保持hash的值不重复(这个好像意义不大)
dict_uniq ()
{
    local -n _dict_uniq_ref_arr="${1}"
    local -n _dict_uniq_ref_out_arr="${2}"

    local -A _dict_uniq_element_hash=()
    local _dict_uniq_i

    for _dict_uniq_i in "${!_dict_uniq_ref_arr[@]}" ; do
        local _dict_uniq_tmp_key="${_dict_uniq_ref_arr["$_dict_uniq_i"]}"
        # :TODO: 值为空的直接排除是否合理?
        [[ -z "$_dict_uniq_tmp_key" ]] && continue
        if [[ -z "${_dict_uniq_element_hash["$_dict_uniq_tmp_key"]}" ]] ; then
            _dict_uniq_element_hash["$_dict_uniq_tmp_key"]=1
            _dict_uniq_ref_out_arr["$_dict_uniq_i"]="$_dict_uniq_tmp_key"
        fi
    done
}

return 0

