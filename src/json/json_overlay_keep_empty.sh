. ./meta/meta.sh
((DEFENSE_VARIABLES[json_overlay_keep_empty]++)) && return 0

. ./json/json_set_params_check.sh || return 1
. ./json/json_del_keep_empty.sh || return 1
. ./json/json_set.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1

# 一个结构体覆盖另外一个结构体的某个子健(如果原有子健下挂内容,先删除)
# :TODO: 挂接失败可能导致父数据结构也被改变了,这是否需要还原?或者是一开始保存一份?
# 如果子健不存在,就创建
# 返回值:
#   bit0: 传入的设置参数不合法
#   其它: json_set的返回值
json_overlay_keep_empty ()
{
    local -n _json_overlay_{father_json_ref="$1",son_json_ref="$2"}
    # 注意这里,如果要挂接的是关联数组的键[key]形式传入,否则用数字键
    shift 2
    local -a _json_overlay_add_keys=("${@}")
    local -a _json_overlay_add_keys_nude=("${@}")
    local _json_overlay_{param_left_padding=,param_right_padding=,son_index=,ret_code=0}
    
    # 参数合法性检查
    json_set_params_check "${_json_overlay_add_keys[@]}" || return 1

    local -i _json_overlay_is_son_json_null=1

    if [[ "${_json_overlay_son_json_ref@a}" == *A* ]] ; then
        _json_overlay_param_left_padding='['
        _json_overlay_param_right_padding=']'
    fi

    # 先清除原始键(这里不用判断错误),需要删除中括号
    json_set_params_del_bracket '_json_overlay_add_keys_nude'
    json_del_keep_empty _json_overlay_father_json_ref "${_json_overlay_add_keys_nude[@]}"

    # 开始挂接(子数是数组和关联数组传入的参数是不同的)
    for _json_overlay_son_index in "${!_json_overlay_son_json_ref[@]}" ; do
        _json_overlay_is_son_json_null=0
        json_set _json_overlay_father_json_ref "${_json_overlay_add_keys[@]}" "${_json_overlay_param_left_padding}${_json_overlay_son_index}${_json_overlay_param_right_padding}" '' "${_json_overlay_son_json_ref["$_json_overlay_son_index"]}"
        _json_overlay_ret_code=$?
        ((_json_overlay_ret_code)) && return $_json_overlay_ret_code
    done  
    
    # 空数组或者空hash
    if ((_json_overlay_is_son_json_null)) ; then
        if [[ "${_json_overlay_son_json_ref@a}" == *A* ]] ; then
            local _json_overlay_set_value='declare -A _json_set_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev1=()'
        else
            local _json_overlay_set_value='declare -a _json_set_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev1=()'
        fi
        json_set _json_overlay_father_json_ref "${_json_overlay_add_keys[@]}" - "$_json_overlay_set_value"
        _json_overlay_ret_code=$?
        ((_json_overlay_ret_code)) && return $_json_overlay_ret_code
    fi
    
    return 0
}

return 0

