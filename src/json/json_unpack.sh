. ./meta/meta.sh
((DEFENSE_VARIABLES[json_unpack]++)) && return 0

# :TODO: 整个结构体是否需要重构?传参统一使用Q字符串？安全？或者没有必要，暂时不实现
# :TODO: 或者这么说，是否需要传参的地方都用@Q安全字符串来处理？
# 但是@Q和printf "%q" 提供了额外的保护层
# var='some string with special characters & $(rm -rf /)'
# printf "%q\n" "$var"
#
# json_unpack 0 str "json_name"
# 压缩后的结构体(原始字符串或者是Q字符串)解压成结构体
# 参数:
#   1: 字符串类型
#       0: 普通字符串
#       1: Q字符串
#   2: 压缩后的结构体字符串
#   3: 解压后的结构体的名字(数据类型必须申请正确),注意这里不是引用,是名字

json_unpack ()
{
    local -i _json_unpack_str_type=$1
    local _json_unpack_str=$2

    # 如果本身是一个Q字符串,先转换成普通字符串
    if ((_json_unpack_str_type)) ; then
        eval "_json_unpack_str=$_json_unpack_str"
    fi

    # 普通字符串拿到申明后的数据部分
    if [[ "$_json_unpack_str" =~ ^(declare)\ ([^\ ]+)\ _json_set_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev[0-9]+=(.*) ]] ; then
        # 这里不能重新声明,因为重新声明就变成局部变量了,所以变量的类型和解压的类型必须一致
        eval "$3=${BASH_REMATCH[3]}"
    fi
}

alias json_unpack_o='json_unpack 0'
alias json_unpack_q='json_unpack 1'

return 0

