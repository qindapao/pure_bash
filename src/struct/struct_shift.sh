. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_shift]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./array/array_shift.sh || return 1
. ./struct/struct_get_field.sh || return 1
. ./struct/struct_del_field.sh || return 1
. ./struct/struct_set_params_del_bracket.sh || return 1
. ./struct/struct_overlay_subtree.sh || return 1

# 对某级下挂的数组shift第一个元素到标准输出,并且删除这个元素
# struct_shift 'struct_name' 'ret' '4' '0' '[key1]'
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
#   struct_get_field 的返回值
struct_shift ()
{
    local -n _struct_shift_struct_ret=$1 _struct_shift_struct_ref=$2
    shift 2

    local -a _struct_shift_get_params=("${@}")
    struct_set_params_del_bracket _struct_shift_get_params

    local -a _struct_shift_get_array=() _struct_shift_get_array_indexs=()
    local -i _struct_shift_get_array_max_index=-1 _struct_shift_return_code=0
    struct_get_field _struct_shift_get_array _struct_shift_struct_ref "${_struct_shift_get_params[@]}"
    _struct_shift_return_code=$?
    if ((_struct_shift_return_code)) ; then
        return $_struct_shift_return_code
    fi
    _struct_shift_return_code=0

    # 删除数组的第一个元素
    array_shift _struct_shift_get_array _struct_shift_struct_ret

    if ! ((${#_struct_shift_get_array[@]})) ; then
        # 如果已经是空数组,那么原始数组删除键
        struct_del_field _struct_shift_struct_ref "${_struct_shift_get_params[@]}"
        _struct_shift_return_code=$?
        ((_struct_shift_return_code)) && ((_struct_shift_return_code|=64))
        return $_struct_shift_return_code
    fi

    # 数组重构
    struct_overlay_subtree _struct_shift_struct_ref _struct_shift_get_array "${@}"
    _struct_shift_return_code=$?
    ((_struct_shift_return_code)) && ((_struct_shift_return_code|=128))
    return $_struct_shift_return_code
}

return 0

