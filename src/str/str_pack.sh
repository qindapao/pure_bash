. ./meta/meta.sh
((DEFENSE_VARIABLES[str_pack]++)) && return 0

# 把任何的内置数组结构转换成字符串形式(要求数据结构在外部必须初始化)
# 数据结构的
# 参数:
#   1: 外部数据的引用
#   2: 需要转换成的字符串类型
#       0: 原始字符串(默认)
#       1: Q字符串(可以用于安全的参数)
#       :TODO: 这里注意下,Q字符串可以用于复杂传参,并且通过expect传递到另外的主机
#               这种情况下可能双引号都不能保证字符串安全的，就需要用到Q字符串
#               到另外的主机后再用eval解码即可
# :TODO: 待验证
str_pack ()
{
    local -n _str_pack_var_ref=$1
    local -i _str_pack_str_type=${2:-0}
    # 完整申明字符串
    # @A的语法是Bash4.4引入的,谨慎使用啊
    local _str_pack_declare_str="${_str_pack_var_ref[@]@A}"
    
    if [[ "$_str_pack_declare_str" =~ ^declare\ [^\ ]+\ [a-zA-Z_]+[a-zA-Z0-9_]*=(.*) ]] ; then
        case "$_str_pack_str_type" in
        0)  printf "%s" "${BASH_REMATCH[1]}" ;;
        1)  printf "%q" "${BASH_REMATCH[1]}" ;;
        esac
    else
        case "$_str_pack_str_type" in
        0)  printf "%s" "${_str_pack_declare_str#*=}" ;;
        1)  printf "%q" "${_str_pack_declare_str#*=}" ;;
        esac
    fi
}

return 0

