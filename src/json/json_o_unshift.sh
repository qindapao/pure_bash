. ./meta/meta.sh
((DEFENSE_VARIABLES[json_o_unshift]++)) && return 0

. ./json/json_common.sh || return 1
. ./log/log_dbg.sh || return 1
. ./array/array_unshift.sh || return 1
. ./json/json_get.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1
. ./json/json_overlay.sh || return 1
. ./json/json_pack.sh || return 1

# 对某级下挂的数组unshift一个元素进去(放置在数组的开头)
# 和json_unshift 不同的是这里压入引用,并不是值
# json_unshift 'json_name' '4' '0' '[key1]' '' "value"
# 返回值:
#   bit7: 
#       0:获取结构体的时候出错
#       1:挂接子树的时候出错
json_o_unshift ()
{
    local -n _json_unshift_json_ref=$1
    local -n _json_unshift_json_son_ref=$2
    shift 2

    local _json_unshift_json_son_pack_str=''
    json_pack_o _json_unshift_json_son_ref '_json_unshift_json_son_pack_str'

    local -i _json_unshift_return_code=0
    (($#)) || {
        array_unshift _json_unshift_json_ref "$_json_unshift_json_son_pack_str"
        return $?
     }

    local -a _json_unshift_get_params=("${@}")
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

    array_unshift _json_unshift_get_array "$_json_unshift_json_son_pack_str"

    # 把得到的新数组重新挂接子树
    json_overlay _json_unshift_json_ref _json_unshift_get_array "${@}"
}

return 0

