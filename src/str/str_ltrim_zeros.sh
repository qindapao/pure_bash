. ./meta/meta.sh
((DEFENSE_VARIABLES[str_ltrim_zeros]++)) && return 0

# 去掉前导0(如果单纯只有一个0需要保留)
# 1: 高阶函数的索引
# 2: 需要操作的字符串值
# 3: 需要操作的字符串的变量名(如果不传默认打印到标准输出)
str_ltrim_zeros ()
{
    local _str_ltrim_zeros_out_str=''
    printf -v _str_ltrim_zeros_out_str "%s" "${2#"${2%%[!0]*}"}" 
    # extglob实现
    # shopt -s extglob ; printf -v _str_ltrim_zeros_out_str "%s" "${2##+(0)}"

    if [[ -n "$3" ]] ; then
        if [[ -z "$_str_ltrim_zeros_out_str" ]] ; then
            printf -v "$3" "%s" "${2:0:1}"
        else
            printf -v "$3" "%s" "$_str_ltrim_zeros_out_str"
        fi
    else
        if [[ -z "$_str_ltrim_zeros_out_str" ]] ; then
            printf "%s" "${2:0:1}"
        else
            printf "%s" "$_str_ltrim_zeros_out_str"
        fi
    fi
}

alias str_ltrim_zeros_s='str_ltrim_zeros ""'

return 0

