. ./meta/meta.sh
((DEFENSE_VARIABLES[json_shift_ke]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./json/json_common.sh || return 1
. ./array/array_shift.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1
. ./json/json_overlay.sh || return 1
. ./json/json_unpack.sh || return 1

# 对某级下挂的数组shift第一个元素到标准输出,并且删除这个元素
# json_shift_ke 'json_name' 'ret' '4' '0' '[key1]'
# 参数:
#   1: shift的元素保存的变量
#   2: 需要shift的数组的引用
#   @: 数组的每级索引
#
# 返回值:
#   bit7: 
#       0:获取结构体的时候出错
#       1:重组结构体的时候出错
#   bit6:
#       1:删除结构体的时候出错
#   json_get 的返回值
json_shift_ke ()
{
    local -n _json_shift_ke_json_{ret="$1",ref="$2"}
    shift 2

    local -i _json_shift_ke_return_code=0
    local _json_shift_ke_json_str

    (($#)) || {
        # 普通数组
        if ((${#_json_shift_ke_json_ref[@]})) ; then
            if [[ "${_json_shift_ke_json_ref@a}" == *a* ]] ; then
                array_shift _json_shift_ke_json_ref _json_shift_ke_json_str
                json_unpack_o "$_json_shift_ke_json_str" _json_shift_ke_json_ret
                _json_shift_ke_return_code=$?
                ((_json_shift_ke_return_code)) && return $_json_shift_ke_return_code
                return ${JSON_COMMON_ERR_DEFINE[ok]}
            else
                # 非数组
                return ${JSON_COMMON_ERR_DEFINE[shift_not_array]}
            fi
        else
            return ${JSON_COMMON_ERR_DEFINE[shift_null_array]}
        fi
    }

    local -a _json_shift_ke_get_params=("${@}")
    json_set_params_del_bracket _json_shift_ke_get_params

    local -a _json_shift_ke_get_array=() _json_shift_ke_get_array_indexs=()
    local -i _json_shift_ke_get_array_max_index=-1
    json_get _json_shift_ke_get_array _json_shift_ke_json_ref "${_json_shift_ke_get_params[@]}"
    _json_shift_ke_return_code=$?
    if ((_json_shift_ke_return_code)) ; then
        return $_json_shift_ke_return_code
    fi
    _json_shift_ke_return_code=0

    # 删除数组的第一个元素
    if ((${#_json_shift_ke_get_array[@]})) ; then
        array_shift _json_shift_ke_get_array _json_shift_ke_json_str
        json_unpack_o "$_json_shift_ke_json_str" _json_shift_ke_json_ret
        _json_shift_ke_return_code=$?
        ((_json_shift_ke_return_code)) && return $_json_shift_ke_return_code
    else
        return ${JSON_COMMON_ERR_DEFINE[shift_null_array]}
    fi

    # 数组重构
    json_overlay _json_shift_ke_json_ref _json_shift_ke_get_array "${@}"
}

return 0

