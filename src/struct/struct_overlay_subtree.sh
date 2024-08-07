. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_overlay_subtree]++)) && return 0

. ./struct/struct_set_params_check.sh || return 1
. ./struct/struct_del_field.sh || return 1
. ./struct/struct_set_field.sh || return 1
. ./struct/struct_set_params_del_bracket.sh || return 1

# 一个结构体覆盖另外一个结构体的某个子健(如果原有子健下挂内容,先删除)
# :TODO: 挂接失败可能导致父数据结构也被改变了,这是否需要还原?或者是一开始保存一份?
# 如果子健不存在,就创建
# 返回值:
#   bit0: 传入的设置参数不合法
#   其它: struct_set_field的返回值
struct_overlay_subtree ()
{
    local -n _struct_overlay_subtree_{father_struct_ref="$1",son_struct_ref="$2"}
    # 注意这里,如果要挂接的是关联数组的键[key]形式传入,否则用数字键
    shift 2
    local -a _struct_overlay_subtree_add_keys=("${@}")
    local -a _struct_overlay_subtree_add_keys_nude=("${@}")
    local _struct_overlay_subtree_{param_left_padding=,param_right_padding=,son_index=,ret_code=0}
    
    # 参数合法性检查
    struct_set_params_check "${_struct_overlay_subtree_add_keys[@]}" || return 1

    if [[ "${_struct_overlay_subtree_son_struct_ref@a}" == *A* ]] ; then
        _struct_overlay_subtree_param_left_padding='['
        _struct_overlay_subtree_param_right_padding=']'
    fi

    # 先清除原始键(这里不用判断错误),需要删除中括号
    struct_set_params_del_bracket '_struct_overlay_subtree_add_keys_nude'
    struct_del_field _struct_overlay_subtree_father_struct_ref "${_struct_overlay_subtree_add_keys_nude[@]}"

    # 开始挂接(子数是数组和关联数组传入的参数是不同的)
    for _struct_overlay_subtree_son_index in "${!_struct_overlay_subtree_son_struct_ref[@]}" ; do
        struct_set_field _struct_overlay_subtree_father_struct_ref "${_struct_overlay_subtree_add_keys[@]}" "${_struct_overlay_subtree_param_left_padding}${_struct_overlay_subtree_son_index}${_struct_overlay_subtree_param_right_padding}" '' "${_struct_overlay_subtree_son_struct_ref["$_struct_overlay_subtree_son_index"]}"
        _struct_overlay_subtree_ret_code=$?
        ((_struct_overlay_subtree_ret_code)) && return $_struct_overlay_subtree_ret_code
    done  
    
    return 0
}

return 0

