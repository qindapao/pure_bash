. ./meta/meta.sh
((DEFENSE_VARIABLES[json_map_to_json]++)) && return 0

. ./json/json_quote.sh || return 1

# 关联数组变成JSON字符串
json_map_to_json () {
    local -n __json_map_to_json_map_ref="$1"
    local -n __json_map_to_json_out_json_str="$2"
    local __json_map_to_json_key

    (("${#__json_map_to_json_map_ref[@]}")) || {
        __json_map_to_json_out_json_str="{}"
        return
    }

    __json_map_to_json_out_json_str="{"
    for __json_map_to_json_key in "${!__json_map_to_json_map_ref[@]}"; do
        local __json_map_to_json_k="$__json_map_to_json_key"
        local __json_map_to_json_v="${__json_map_to_json_map_ref[$__json_map_to_json_key]}"
        json_quote __json_map_to_json_k
        json_quote __json_map_to_json_v
        __json_map_to_json_out_json_str+="$__json_map_to_json_k:$__json_map_to_json_v,"
    done
    __json_map_to_json_out_json_str="${__json_map_to_json_out_json_str%,}}"
}

return 0

