. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_pop]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./struct/struct_get_field.sh || return 1
. ./struct/struct_del_field.sh || return 1
. ./struct/struct_set_params_del_bracket.sh || return 1
. ./struct/struct_overlay_subtree.sh || return 1

# 对某级下挂的数组pop最后一个元素到标准输出,并且删除这个元素
# xx=$(struct_pop 'struct_name' '4' '0' '[key1]')
# 参数:
#   1: 需要pop的数组的引用
#   @: 数组的每级索引
#
# 返回值:
#   bit7: 
#       0:获取结构体的时候出错
#       1:重组结构体的时候出错
#   bit6:
#       1:删除结构体的时候出错
#   struct_get_field 的返回值
struct_pop ()
{
    local -n _struct_pop_struct_ref="${1}"
    shift

    local -a _struct_pop_get_params=("${@}")
    struct_set_params_del_bracket _struct_pop_get_params

    local -a _struct_pop_get_array=() _struct_pop_get_array_indexs=()
    local -i _struct_pop_get_array_max_index=-1 _struct_pop_return_code=0
    struct_get_field _struct_pop_struct_ref _struct_pop_get_array "${_struct_pop_get_params[@]}"
    _struct_pop_return_code=$?
    if ((_struct_pop_return_code)) ; then
        return $_struct_pop_return_code
    fi
    _struct_pop_return_code=0

    # 数组删除最后一个元素
    printf "%s" "${_struct_pop_get_array[-1]}"
    unset _struct_pop_get_array[-1]

    if ! ((${#_struct_pop_get_array[@]})) ; then
        # 如果已经是空数组,那么原始数组删除键
        struct_del_field _struct_pop_struct_ref "${_struct_pop_get_params[@]}"
        _struct_pop_return_code=$?
        ((_struct_pop_return_code)) && ((_struct_pop_return_code|=64))
        return $_struct_pop_return_code
    fi

    # 数组重构
    struct_overlay_subtree _struct_pop_struct_ref _struct_pop_get_array "${@}"
    _struct_pop_return_code=$?
    ((_struct_pop_return_code)) && ((_struct_pop_return_code|=128))
    return $_struct_pop_return_code
}

return 0

