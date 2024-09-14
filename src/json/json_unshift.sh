. ./meta/meta.sh
((DEFENSE_VARIABLES[json_unshift]++)) && return 0

. ./log/log_dbg.sh || return 1
. ./array/array_unshift.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_set.sh || return 1
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

   local -a _json_unshift_get_params=("${@:1:$#-2}")
    json_set_params_del_bracket _json_unshift_get_params

   local -a _json_unshift_get_array=() _json_unshift_get_array_indexs=()
   local -i _json_unshift_get_array_max_index=-1 _json_unshift_return_code=0
   json_get _json_unshift_get_array _json_unshift_json_ref "${_json_unshift_get_params[@]}"
   _json_unshift_return_code=$?
   if ((_json_unshift_return_code)) && ! (((_json_unshift_return_code>>2)&1)) ; then
       return $_json_unshift_return_code
    fi
    _json_unshift_return_code=0

    local _json_unshift_set_flag="${@:$#-1:1}" ; _json_unshift_set_flag="${_json_unshift_set_flag:--}"
    declare -"${_json_unshift_set_flag}" _json_unshift_set_value="${@:$#:1}"
    array_unshift _json_unshift_get_array "$_json_unshift_set_value"

    # 把得到的新数组重新挂接子树
    json_overlay _json_unshift_json_ref _json_unshift_get_array "${@:1:$#-2}"
    _json_unshift_return_code=$?
    ((_json_unshift_return_code)) && ((_json_unshift_return_code|=128))
    
    return $_json_unshift_return_code
}

return 0

