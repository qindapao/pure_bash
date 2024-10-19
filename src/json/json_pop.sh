. ./meta/meta.sh
((DEFENSE_VARIABLES[json_pop]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./json/json_common.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_del.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1
. ./json/json_overlay.sh || return 1
. ./json/json_unpack.sh || return 1

# pop函数也是不需要de函数的,因为如果数组本身致密,那么pop后也是致密的
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
json_pop ()
{
    local -n _json_pop_out_var=$1 _json_pop_json_ref=$2
    shift 2
    
    local -i _json_pop_return_code=0

    (($#)) || {
        # 普通数组
        if ((${#_json_pop_json_ref[@]})) ; then
            if [[ "${_json_pop_json_ref@a}" == *a* ]] ; then
                json_unpack_o "${_json_pop_json_ref[-1]}" _json_pop_out_var
                _json_pop_return_code=$?
                ((_json_pop_return_code)) && return $_json_pop_return_code
                unset -v '_json_pop_json_ref[-1]'
                return ${JSON_COMMON_ERR_DEFINE[ok]}
            else
                # 非数组
                return ${JSON_COMMON_ERR_DEFINE[pop_not_array]}
            fi
        else
            return ${JSON_COMMON_ERR_DEFINE[pop_null_array]}
        fi
    }

    local -a _json_pop_get_params=("${@}")
    json_set_params_del_bracket _json_pop_get_params

    local -a _json_pop_get_array=() _json_pop_get_array_indexs=()
    local -i _json_pop_get_array_max_index=-1
    json_get _json_pop_get_array _json_pop_json_ref "${_json_pop_get_params[@]}"
    _json_pop_return_code=$?
    if ((_json_pop_return_code)) ; then
        return $_json_pop_return_code
    fi
    _json_pop_return_code=0

    # str_pack 打包后可以直接在外部拿到数组
    # 数组删除最后一个元素
    if ((${#_json_pop_get_array[@]})) ; then
        json_unpack_o "${_json_pop_get_array[-1]}" _json_pop_out_var
        _json_pop_return_code=$?
        ((_json_pop_return_code)) && return $_json_pop_return_code
        unset -v '_json_pop_get_array[-1]'
    else
        return ${JSON_COMMON_ERR_DEFINE[pop_null_array]}
    fi

    if ! ((${#_json_pop_get_array[@]})) ; then
        # 如果已经是空数组,那么原始数组删除键
        json_del _json_pop_json_ref "${_json_pop_get_params[@]}"
        _json_pop_return_code=$?
        ((_json_pop_return_code)) && ((_json_pop_return_code|=64))
        return $_json_pop_return_code
    fi

    # 数组重构
    json_overlay _json_pop_json_ref _json_pop_get_array "${@}"
    _json_pop_return_code=$?
    ((_json_pop_return_code)) && ((_json_pop_return_code|=128))
    return $_json_pop_return_code
}

return 0

