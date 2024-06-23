
. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_set_union]++)) && return 0

# hash模拟集合的并集
dict_set_union ()
{
    local -n _dict_set_union_ref_result_hash="${1}"
    shift

    local _dict_set_union_key
    
    while(($#)) ; do
        local -n _dict_set_union_tmp_hash="${1}"
        for _dict_set_union_key in "${!_dict_set_union_tmp_hash[@]}" ; do
            _dict_set_union_ref_result_hash["$_dict_set_union_key"]=1
        done
        
        (($#)) && shift
    done
}

return 0

