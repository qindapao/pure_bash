. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_unpack]++)) && return 0

# . ./log/log_dbg.sh || return 1

# :TODO: 整个结构体是否需要重构?传参统一使用Q字符串？安全？或者没有必要，暂时不实现
# :TODO: 或者这么说，是否需要传参的地方都用@Q安全字符串来处理？
# 但是@Q和printf "%q" 提供了额外的保护层
# var='some string with special characters & $(rm -rf /)'
# printf "%q\n" "$var"
#
# struct_unpack 0 str "struct_name"
# 压缩后的结构体(原始字符串或者是Q字符串)解压成结构体
# 参数:
#   1: 字符串类型
#       0: 普通字符串
#       1: Q字符串
#   2: 压缩后的结构体字符串
#   3: 解压后的结构体的名字(数据类型必须申请正确),注意这里不是引用,是名字

struct_unpack ()
{
    local -i _struct_unpack_str_type="${1}"
    local _struct_unpack_str="${2}"
    local _struct_unpack_struct_name="${3}"

    # 如果本身是一个Q字符串,先转换成普通字符串
    if ((_struct_unpack_str_type)) ; then
        eval "_struct_unpack_str=$_struct_unpack_str"
    fi

    # 普通字符串拿到申明后的数据部分
    if [[ "$_struct_unpack_str" =~ ^(declare)\ ([^\ ]+)\ _struct_set_field_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev[0-9]+=(.*) ]] ; then
        # 这里不能重新声明,因为重新声明就变成局部变量了,所以变量的类型和解压的类型必须一致
        eval "$_struct_unpack_struct_name=${BASH_REMATCH[3]}"
    fi
}

return 0

