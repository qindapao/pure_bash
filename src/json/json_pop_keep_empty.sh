. ./meta/meta.sh
((DEFENSE_VARIABLES[json_pop_keep_empty]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1
. ./json/json_overlay_keep_empty.sh || return 1

# 对某级下挂的结构体pop最后一个元素到标准输出,并且删除这个元素
# json_pop xx 'json_name' '4' '0' '[key1]'
# 参数:
#   1: 需要pop的数组的引用
#   @: 数组的每级索引
#
# 返回值:
#   bit7: 
#       0:获取结构体的时候出错
#       1:重组结构体的时候出错
#   bit6:
#       1:删除结构体的时候出错
#   json_get 的返回值
json_pop_keep_empty ()
{
    local -n _json_pop_out_var=$1 _json_pop_json_ref=$2
    shift 2

    local -a _json_pop_get_params=("${@}")
    json_set_params_del_bracket _json_pop_get_params

    local -a _json_pop_get_array=() _json_pop_get_array_indexs=()
    local -i _json_pop_get_array_max_index=-1 _json_pop_return_code=0
    json_get _json_pop_get_array _json_pop_json_ref "${_json_pop_get_params[@]}"
    _json_pop_return_code=$?
    if ((_json_pop_return_code)) ; then
        return $_json_pop_return_code
    fi
    _json_pop_return_code=0

    # :TODO: 是直接返回还是打包后返回(如果不是叶子数组)实际使用中再看
    # str_pack 打包后可以直接在外部拿到数组
    # 数组删除最后一个元素
    if ((${#_json_pop_get_array[@]})) ; then
        _json_pop_out_var="${_json_pop_get_array[-1]}"
        unset '_json_pop_get_array[-1]'
    else
        _json_pop_out_var=''
        return 128
    fi

    # 数组重构
    json_overlay_keep_empty _json_pop_json_ref _json_pop_get_array "${@}"
    _json_pop_return_code=$?
    ((_json_pop_return_code)) && ((_json_pop_return_code|=128))
    return $_json_pop_return_code
}

return 0

