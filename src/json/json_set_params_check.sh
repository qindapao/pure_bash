. ./meta/meta.sh
((DEFENSE_VARIABLES[json_set_params_check]++)) && return 0

. ./json/json_common.sh || return 1

# 结构体设置类参数检查
# :TODO: 返回值的错误类型是否还需要细化?
# 返回值:
#   bit0: 参数格式错误
json_set_params_check ()
{
    local -a _json_set_params_check_set_params=("${@}")
    # 如果是[]包裹非空即可,如果不是[]包裹只能是10进制数字
    ((${#_json_set_params_check_set_params[@]})) || return ${JSON_COMMON_ERR_DEFINE[set_no_params]}
    local _json_set_params_check_elment=''
    
    for _json_set_params_check_elment in "${_json_set_params_check_set_params[@]}" ; do
        if [[ "${_json_set_params_check_elment:0:1}" == '[' ]] && [[ "${_json_set_params_check_elment: -1}" == ']' ]] ; then
            # 非空键判断
            [[ -z "${_json_set_params_check_elment:1:-1}" ]] && return ${JSON_COMMON_ERR_DEFINE[set_null_key]}
        else
            # 必须是严格10进制数
            [[ "$_json_set_params_check_elment" =~ ^[1-9][0-9]*$|^0$ ]] || return ${JSON_COMMON_ERR_DEFINE[set_key_index_not_decimal]}
        fi
    done
    
    return ${JSON_COMMON_ERR_DEFINE[ok]}
}

return 0

