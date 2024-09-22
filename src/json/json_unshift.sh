. ./meta/meta.sh
((DEFENSE_VARIABLES[json_unshift]++)) && return 0

. ./json/json_common.sh || return 1
. ./log/log_dbg.sh || return 1
. ./array/array_unshift.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1
. ./json/json_overlay.sh || return 1

# 对某级下挂的数组unshift一个元素进去(放置在数组的开头)
# json_unshift 'json_name' '4' '0' '[key1]' '' "value"
# 返回值:
#   bit7: 
#       0:获取结构体的时候出错
#       1:挂接子树的时候出错
json_unshift ()
{
    local -n _json_unshift_json_ref=$1
    shift

    local _json_unshift_set_flag="${@:$#-1:1}" ; _json_unshift_set_flag="${_json_unshift_set_flag:--}"
    local -i _json_unshift_return_code=0
    declare -"${_json_unshift_set_flag}" _json_unshift_set_value="${@:$#:1}"
    if (($#==2)) ; then
         array_unshift _json_unshift_json_ref "$_json_unshift_set_value"
         return $?
    fi

    local -a _json_unshift_get_params=("${@:1:$#-2}")
    json_set_params_del_bracket _json_unshift_get_params

    local -a _json_unshift_get_array=()
    json_get _json_unshift_get_array _json_unshift_json_ref "${_json_unshift_get_params[@]}"
    _json_unshift_return_code=$?
    # 大概意思是就算没有获取到原始键也没有关系,依然可以往里面overlay写入
    # if ((_json_unshift_return_code)) && ! (((_json_unshift_return_code>>2)&1)) ; then
    # 就是说获取出错,并且错误是键不存在,都是可以继续的(如果unshfit一个很深的数组是可以的,会自动创建)
    if ((_json_unshift_return_code)) && ((_json_unshift_return_code!=JSON_COMMON_ERR_DEFINE[get_key_not_found])) ; then
       return $_json_unshift_return_code
    fi

    array_unshift _json_unshift_get_array "$_json_unshift_set_value"

    # 把得到的新数组重新挂接子树
    json_overlay _json_unshift_json_ref _json_unshift_get_array "${@:1:$#-2}"
}

return 0

