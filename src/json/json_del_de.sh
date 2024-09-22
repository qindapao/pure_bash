. ./meta/meta.sh
((DEFENSE_VARIABLES[json_del_de]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./json/json_common.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_del.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1
. ./json/json_overlay.sh || return 1


# :注意: 这个函数只能用于处理数组,不能处理关联数组

# 对某级下挂的结构体删除元素到标准输出,并且删除这个元素,如果是数组会删除稀疏元素
# json_del_de out_var 'json_name' '4' '0' '[key1]'
# 参数:
#   1: 删除的元素保存的变量名
#   2: 需要pop的数组的引用
#   @: 数组的每级索引
#
# 返回值:
#   bit7: 
#       0:获取结构体的时候出错
#       1:重组结构体的时候出错
#   bit6:
#       1:删除结构体的时候出错
#   json_get 的返回值
json_del_de ()
{
    local -n _json_del_de_json_ref=$1
    shift 1

    # 如果剩下的参数只有一个,证明是数组的情况
    local _json_del_de_delete_key="${!#}"
    if (($#==1)) ; then
        unset -v '_json_del_de_json_ref[_json_del_de_delete_key]'
        _json_del_de_json_ref=("${_json_del_de_json_ref[@]}")
        return ${JSON_COMMON_ERR_DEFINE[ok]}
    fi

    local -a _json_del_de_get_params=("${@:1:$#-1}")
    local -a _json_del_de_get_params_ori=("${@:1:$#-1}")
    json_set_params_del_bracket _json_del_de_get_params

    local -a _json_del_de_get_array=() _json_del_de_get_array_indexs=()
    local -i _json_del_de_get_array_max_index=-1 _json_del_de_return_code=0
    json_get _json_del_de_get_array _json_del_de_json_ref "${_json_del_de_get_params[@]}"
    _json_del_de_return_code=$?
    if ((_json_del_de_return_code)) ; then
        return $_json_del_de_return_code
    fi
    _json_del_de_return_code=0

    if ((${#_json_del_de_get_array[@]})) ; then
        unset -v '_json_del_de_get_array[_json_del_de_delete_key]'
    else
        return ${JSON_COMMON_ERR_DEFINE[del_null_array_not_need_handle]}
    fi

    if ! ((${#_json_del_de_get_array[@]})) ; then
        # 如果已经是空数组,那么原始数组删除键
        json_del _json_del_de_json_ref "${_json_del_de_get_params[@]}"
        _json_del_de_return_code=$?
        ((_json_del_de_return_code)) && ((_json_del_de_return_code|=64))
        return $_json_del_de_return_code
    else
        _json_del_de_get_array=("${_json_del_de_get_array[@]}")
    fi

    # 数组重构
    json_overlay _json_del_de_json_ref _json_del_de_get_array "${_json_del_de_get_params_ori[@]}"
    _json_del_de_return_code=$?
    ((_json_del_de_return_code)) && ((_json_del_de_return_code|=128))
    return $_json_del_de_return_code
}

return 0

