. ./meta/meta.sh
((DEFENSE_VARIABLES[json_push]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_set.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1

# 对某级下挂的数组push一个元素进去
# json_push 'json_name' '4' '0' '[key1]' '' "value"
# 返回值:
#   bit7: 
#       0:获取结构体的时候出错
#       1:设置结构体的时候出错
#   json_get 的返回值
json_push ()
{
    local -n _json_push_json_ref=$1
    shift

    local -a _json_push_get_params=("${@:1:$#-2}")
    json_set_params_del_bracket _json_push_get_params

    local -a _json_push_get_array=() _json_push_get_array_indexs=()
    local -i _json_push_get_array_max_index=-1 _json_push_return_code=0
    json_get _json_push_get_array _json_push_json_ref "${_json_push_get_params[@]}"
    _json_push_return_code=$?
    if ((_json_push_return_code)) && ! (((_json_push_return_code>>2)&1)) ; then
        return $_json_push_return_code
    fi
    _json_push_return_code=0

    # 获取数组最大索引
    _json_push_get_array_indexs=("${!_json_push_get_array[@]}")
    if ((${#_json_push_get_array_indexs[@]})) ; then
        _json_push_get_array_max_index="${_json_push_get_array_indexs[-1]}"
    fi
    ((_json_push_get_array_max_index++))
    
    # 往最大索引+1写入值
    json_set _json_push_json_ref "${@:1:$#-2}" "$_json_push_get_array_max_index" "${@:$#-1}"
    _json_push_return_code=$?
    ((_json_push_return_code)) && ((_json_push_return_code|=128))

    return $_json_push_return_code
}

return 0

