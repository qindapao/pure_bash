. ./meta/meta.sh
((DEFENSE_VARIABLES[json_o_push]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./json/json_common.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_set.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1
. ./json/json_overlay.sh || return 1

# :attention: 其实这个函数的实现还可以和json_unshift保持一致,代码更简洁,可能执行
# 效率更高,也不一定高多少
# 对某级下挂的数组push一个元素进去(和json_push不同的是这里传递引用,所以可以push数组)
# json_o_push 'json_name' '4' '0' '[key1]' '' "value"
# 返回值:
#   bit7: 
#       0:获取结构体的时候出错
#       1:设置结构体的时候出错
#   json_get 的返回值
json_o_push ()
{
    local -n _json_push_json_ref=$1
    local -n _json_push_json_son_ref=$2
    shift 2
    local -a _json_push_get_array_indexs=()
    local -i _json_push_get_array_max_index=-1
    local -i _json_push_return_code=0
    # 获取数组最大索引
    _json_push_get_array_indexs=("${!_json_push_json_ref[@]}")
    if ((${#_json_push_get_array_indexs[@]})) ; then
        _json_push_get_array_max_index="${_json_push_get_array_indexs[-1]}"
    fi
    ((_json_push_get_array_max_index++))

    # push顶级的极端情况
    (($#)) || {
        declare -p _json_push_get_array_max_index
        json_overlay _json_push_json_ref _json_push_json_son_ref "$_json_push_get_array_max_index"
        return $?
    }

    local -a _json_push_get_params=("${@}")
    json_set_params_del_bracket _json_push_get_params

    local -a _json_push_get_array=()
    json_get _json_push_get_array _json_push_json_ref "${_json_push_get_params[@]}"
    _json_push_return_code=$?
    # 大概意思是就算没有获取到原始键也没有关系,依然可以往里面overlay写入
    # if ((_json_unshift_return_code)) && ! (((_json_unshift_return_code>>2)&1)) ; then
    # 就是说获取出错,并且错误是键不存在,都是可以继续的(如果unshfit一个很深的数组是可以的,会自动创建)
    if ((_json_push_return_code)) && ((_json_push_return_code!=JSON_COMMON_ERR_DEFINE[get_key_not_found])) ; then
        return $_json_push_return_code
    fi
 
    # 这里需要重新获取数组最大索引
    _json_push_get_array_max_index=-1
    _json_push_get_array_indexs=("${!_json_push_get_array[@]}")
    if ((${#_json_push_get_array_indexs[@]})) ; then
        _json_push_get_array_max_index="${_json_push_get_array_indexs[-1]}"
    fi
    ((_json_push_get_array_max_index++))

    # 往最大索引+1写入值
    delcare -p _json_push_get_params _json_push_get_array_max_index
    json_overlay _json_push_json_ref _json_push_json_son_ref "${_json_push_get_params[@]}" "$_json_push_get_array_max_index"
}

return 0

