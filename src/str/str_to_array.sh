. ./meta/meta.sh
((DEFENSE_VARIABLES[str_to_array]++)) && return 0

# 字符串转换成数组
str_to_array ()
{
    local _str_to_array_in_str=$1
    local -n _str_to_array_out_arr=$2
    local delimiter="${3}"
    # 不要使用<<<防止多一个回车符号
    # :TODO: 嵌入式环境中< <()语法可能失效,提示没有相关的文件描述符
    IFS="$delimiter" read -d '' -r -a _str_to_array_out_arr < <(printf "%s" "$_str_to_array_in_str")
}

return 0

