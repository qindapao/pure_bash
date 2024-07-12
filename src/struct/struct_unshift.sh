. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_unshift]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./array/array_unshift.sh || return 1
. ./struct/struct_get_field.sh || return 1
. ./struct/struct_set_field.sh || return 1
. ./struct/struct_set_params_del_bracket.sh || return 1
. ./struct/struct_overlay_subtree.sh || return 1

# 对某级下挂的数组unshift一个元素进去(放置在数组的开头)
# struct_unshift 'struct_name' '4' '0' '[key1]' '' "value"
# 返回值:
#   bit7: 
#       0:获取结构体的时候出错
#       1:挂接子树的时候出错
struct_unshift ()
{
    local -n _struct_unshift_struct_ref=$1
    shift

    local -a _struct_unshift_get_params=("${@:1:$#-2}")
    struct_set_params_del_bracket _struct_unshift_get_params

    local -a _struct_unshift_get_array=() _struct_unshift_get_array_indexs=()
    local -i _struct_unshift_get_array_max_index=-1 _struct_unshift_return_code=0
    struct_get_field _struct_unshift_get_array _struct_unshift_struct_ref "${_struct_unshift_get_params[@]}"
    _struct_unshift_return_code=$?
    if ((_struct_unshift_return_code)) && ! (((_struct_unshift_return_code>>2)&1)) ; then
        return $_struct_unshift_return_code
    fi
    _struct_unshift_return_code=0

    local _struct_unshift_set_flag="${@:$#-1:1}" ; _struct_unshift_set_flag="${_struct_unshift_set_flag:--}"
    declare -"${_struct_unshift_set_flag}" _struct_unshift_set_value="${@:$#:1}"
    array_unshift _struct_unshift_get_array "$_struct_unshift_set_value"

    # 把得到的新数组重新挂接子树
    struct_overlay_subtree _struct_unshift_struct_ref _struct_unshift_get_array "${@:1:$#-2}"
    _struct_unshift_return_code=$?
    ((_struct_unshift_return_code)) && ((_struct_unshift_return_code|=128))
    
    return $_struct_unshift_return_code
}

return 0

