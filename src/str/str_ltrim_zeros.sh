. ./meta/meta.sh
((DEFENSE_VARIABLES[str_ltrim_zeros]++)) && return 0

# 去掉前导0(如果单纯只有一个0需要保留)
str_ltrim_zeros ()
{
    local out_str=''
    printf -v out_str "%s" "${2#"${2%%[!0]*}"}" 
    # extglob实现
    # shopt -s extglob ; printf -v out_str "%s" "${2##+(0)}"

    if [[ -z "$out_str" ]] ; then
        printf "%s" "${2:0:1}"
    else
        printf "%s" "$out_str"
    fi
}

alias str_ltrim_zeros_s='str_ltrim_zeros ""'

return 0

