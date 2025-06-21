. ./meta/meta.sh
((DEFENSE_VARIABLES[json_array_to_json]++)) && return 0

. ./json/json_quote.sh || return 1

# 普通数组变成JSON字符串
json_array_to_json ()
{
    local -n __json_array_to_json_arr_ref="$1"
    local -n __json_array_to_json_out_json_str="$2"
    local __json_array_to_json_item

    (("${#__json_array_to_json_arr_ref[@]}")) || {
        __json_array_to_json_out_json_str="[]"
        return
    }

    __json_array_to_json_out_json_str="["
    for __json_array_to_json_item in "${__json_array_to_json_arr_ref[@]}"; do
        json_quote __json_array_to_json_item
        __json_array_to_json_out_json_str+="$__json_array_to_json_item,"
    done
    __json_array_to_json_out_json_str="${__json_array_to_json_out_json_str%,}]"
}

return 0

