. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_pack]++)) && return 0

# :TODO: 是使用进程替换的方式获取安全字符串还是引用的方式？
# 使用进程替换的方式更直观好用
# safe_q_str=$(struct_pack 'struct_name' 1)
# 把结构体(数组或者关联数组也认为是结构体的特殊形式)打包成安全的Q字符串，可以用着另外的结构体的直接节点
# 要求传入的数据结构必须显示声明数据类型
# 参数:
#   1: 外部是结构体的引用
#   2: 返回的字符串类型
#       0: 默认字符串(可以用于直接挂接节点)
#       1: q字符串(可以用于命令行安全传参,千万不要用Q字符串直接挂接节点!)
# 返回值:
#   bit0: 传入的数据结构不是数组或者关联数组
#   bit1: 传入的是空数组
#   bit2: 未知错误
struct_pack ()
{
    local -n _struct_pack_struct_ref="${1}"

    local -i _struct_pack_is_need_q_str="${2:-0}"
    local _struct_pack_ori_str=''
    local _struct_pack_safe_q_str=''
    
    # 判断数据类型,如果不是数组或者关联数组,直接失败
    [[ "${_struct_pack_struct_ref@a}" != *[aA]* ]] && return 1
    ((${#_struct_pack_struct_ref[@]})) || return 2

    # 获取申明字符串
    _struct_pack_ori_str="${_struct_pack_struct_ref[@]@A}"

    # 更换节点结构体的名字
    if [[ "$_struct_pack_ori_str" =~ ^(declare)\ ([^\ ]+)\ [a-zA-Z_]+[a-zA-Z0-9_]*=(.*) ]] ; then
        _struct_pack_ori_str="${BASH_REMATCH[1]} ${BASH_REMATCH[2]} _struct_set_field_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev2=${BASH_REMATCH[3]}"
        if ((_struct_pack_is_need_q_str)) ; then
            printf "%q" "$_struct_pack_ori_str"
        else
            printf "%s" "$_struct_pack_ori_str"
        fi

        return 0
    else
        return 4
    fi
}

return 0

