. ./meta/meta.sh
((DEFENSE_VARIABLES[json_pack]++)) && return 0

. ./json/json_common.sh || return 1

# :TODO: 是使用进程替换的方式获取安全字符串还是引用的方式？
# 使用进程替换的方式更直观好用
# safe_q_str=$(json_pack_q 'json_name')
# 把结构体(数组或者关联数组也认为是结构体的特殊形式)打包成安全的Q字符串，可以用着另外的结构体的直接节点
# 要求传入的数据结构必须显示声明数据类型
# 参数:
#   1: 返回的字符串类型
#       0: 默认字符串(可以用于直接挂接节点)
#       1: q字符串(可以用于命令行安全传参,千万不要用Q字符串直接挂接节点!)
#   2: 外部是结构体的引用
#   3: 打包后的字符串保存的变量名引用
# 返回值:
#   bit0: 传入的数据结构不是数组或者关联数组
#   bit2: 未知错误
json_pack ()
{
    local -i _json_pack_is_need_q_str=${1:-0}
    local -n _json_pack_json_ref=$2
    local -n _json_pack_out_str=$3
    local _json_pack_ori_str=''
    local _json_pack_safe_q_str=''
    
    # 可以允许字符串
    # [[ "${_json_pack_json_ref@a}" != *[aA]* ]] && return ${JSON_COMMON_ERR_DEFINE[pack_not_dict_array]}
    # 空数组当前可以接受
    # ((${#_json_pack_json_ref[@]})) || return 2

    # 获取申明字符串
    _json_pack_ori_str="${_json_pack_json_ref[@]@A}"

    # 更换节点结构体的名字
    if [[ "$_json_pack_ori_str" =~ ^(declare)\ ([^\ ]+)\ [a-zA-Z_]+[a-zA-Z0-9_]*=(.*) ]] ; then
        _json_pack_ori_str="${BASH_REMATCH[1]} ${BASH_REMATCH[2]} _json_set_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev2=${BASH_REMATCH[3]}"
    else
        _json_pack_ori_str="$_json_pack_json_ref"
    fi

    if ((_json_pack_is_need_q_str)) ; then
        printf -v _json_pack_out_str "%q" "$_json_pack_ori_str"
    else
        printf -v _json_pack_out_str "%s" "$_json_pack_ori_str"
    fi

    return ${JSON_COMMON_ERR_DEFINE[ok]}
}

alias json_pack_o='json_pack 0'
alias json_pack_q='json_pack 1'

return 0

