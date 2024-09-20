. ./meta/meta.sh
((DEFENSE_VARIABLES[json_del_de_ke]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1
. ./json/json_overlay_ke.sh || return 1


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
json_del_de_ke ()
{
    local -n _json_del_de_out_var=$1 _json_del_de_json_ref=$2
    shift 2

    # 如果剩下的参数只有一个,证明是数组的情况
    local _json_del_de_delete_key="${!#}"
    if (($#==1)) ; then
        _json_del_de_out_var="${_json_del_de_json_ref[_json_del_de_delete_key]}"
        unset -v '_json_del_de_json_ref[_json_del_de_delete_key]'
        _json_del_de_json_ref=("${_json_del_de_json_ref[@]}")
        return 0
    fi

    local -a _json_del_de_get_params=("${@:1:$#-1}")
    json_set_params_del_bracket _json_del_de_get_params

    local -a _json_del_de_get_array=() _json_del_de_get_array_indexs=()
    local -i _json_del_de_get_array_max_index=-1 _json_del_de_return_code=0
    json_get _json_del_de_get_array _json_del_de_json_ref "${_json_del_de_get_params[@]}"
    _json_del_de_return_code=$?
    if ((_json_del_de_return_code)) ; then
        return $_json_del_de_return_code
    fi
    _json_del_de_return_code=0

    # :TODO: 是直接返回还是打包后返回(如果不是叶子数组)实际使用中再看
    # str_pack 打包后可以直接在外部拿到数组
    # 数组删除最后一个元素
    if ((${#_json_del_de_get_array[@]})) ; then
        _json_del_de_out_var="${_json_del_de_get_array[_json_del_de_delete_key]}"
        unset '_json_del_de_get_array[_json_del_de_delete_key]'
    else
        _json_del_de_out_var=''
        return 128
    fi

    _json_del_de_get_array=("${_json_del_de_get_array[@]}")

    # 数组重构
    json_overlay_ke _json_del_de_json_ref _json_del_de_get_array "${_json_del_de_get_params[@]}"
    _json_del_de_return_code=$?
    ((_json_del_de_return_code)) && ((_json_del_de_return_code|=128))
    return $_json_del_de_return_code
}

return 0

