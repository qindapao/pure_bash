. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_push]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./struct/struct_get_field.sh || return 1
. ./struct/struct_set_field.sh || return 1
. ./struct/struct_set_params_del_bracket.sh || return 1

# 对某级下挂的数组push一个元素进去
# struct_push 'struct_name' '4' '0' '[key1]' '' "value"
# 返回值:
#   bit7: 
#       0:获取结构体的时候出错
#       1:设置结构体的时候出错
#   struct_get_field 的返回值
struct_push ()
{
    local -n _struct_push_struct_ref=$1
    shift

    local -a _struct_push_get_params=("${@:1:$#-2}")
    struct_set_params_del_bracket _struct_push_get_params

    local -a _struct_push_get_array=() _struct_push_get_array_indexs=()
    local -i _struct_push_get_array_max_index=-1 _struct_push_return_code=0
    struct_get_field _struct_push_get_array _struct_push_struct_ref "${_struct_push_get_params[@]}"
    _struct_push_return_code=$?
    if ((_struct_push_return_code)) && ! (((_struct_push_return_code>>2)&1)) ; then
        return $_struct_push_return_code
    fi
    _struct_push_return_code=0

    # 获取数组最大索引
    _struct_push_get_array_indexs=("${!_struct_push_get_array[@]}")
    if ((${#_struct_push_get_array_indexs[@]})) ; then
        _struct_push_get_array_max_index="${_struct_push_get_array_indexs[-1]}"
    fi
    ((_struct_push_get_array_max_index++))
    
    # 往最大索引+1写入值
    struct_set_field _struct_push_struct_ref "${@:1:$#-2}" "$_struct_push_get_array_max_index" "${@:$#-1}"
    _struct_push_return_code=$?
    ((_struct_push_return_code)) && ((_struct_push_return_code|=128))

    return $_struct_push_return_code
}

return 0

