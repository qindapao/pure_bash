. ./meta/meta.sh
((DEFENSE_VARIABLES[json_insert]++)) && return 0

. ./json/json_common.sh || return 1
. ./log/log_dbg.sh || return 1
. ./array/array_einsert_at.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1
. ./json/json_overlay.sh || return 1

# :attention: 只要使用了json_insert后数组都会变成致密,因为用这个函数说明数组不应该稀疏
# 并且也是把外部的数组当成致密数组来处理
# 对某级下挂的数组push一个元素进去
# json_insert 'json_name' '4' '0' '[key1]' '0' - "value"
# 返回值:
#   bit7: 
#       0:获取结构体的时候出错
#       1:设置结构体的时候出错
#   json_get 的返回值
json_insert ()
{
   local -n _json_insert_json_ref=$1
   shift

   local _json_insert_set_flag="${@:$#-1:1}" ; _json_insert_set_flag="${_json_insert_set_flag:--}"
   local -i _json_insert_return_code=0
   declare -"${_json_insert_set_flag}" _json_insert_set_value="${@:$#:1}"
   if (($#==3)) ; then
        if [[ "${_json_insert_json_ref@a}" == *a* ]] ; then
            array_einsert_at '_json_insert_json_ref' "${@:$#-2:1}" "$_json_insert_set_value" 
            return ${JSON_COMMON_ERR_DEFINE[ok]}
        else
            return ${JSON_COMMON_ERR_DEFINE[insert_type_err]}
        fi
   fi

   local -a _json_insert_get_params=("${@:1:$#-3}")
   json_set_params_del_bracket _json_insert_get_params

   local -a _json_insert_get_array=()
   json_get _json_insert_get_array _json_insert_json_ref "${_json_insert_get_params[@]}"
   _json_insert_return_code=$?
   if ((_json_insert_return_code)) && ((_json_insert_return_code!=JSON_COMMON_ERR_DEFINE[get_key_not_found])) ; then
       return $_json_insert_return_code
    fi

    array_einsert_at '_json_insert_get_array' "${@:$#-2:1}" "$_json_insert_set_value" 

    # 把得到的新数组重新挂接子树
    json_overlay _json_insert_json_ref _json_insert_get_array "${@:1:$#-3}"
}

return 0

