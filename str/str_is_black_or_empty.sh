. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_black_or_empty]++)) && return 0

# 判断一个字符串是否只包含空白字符或者是空字符串
str_is_black_or_empty ()
{
    : "${1#"${1%%[![:space:]]*}"}"
    local deal_str="${_%"${_##*[![:space:]]}"}"
    
    [[ -z "$deal_str" ]] && return 0 || return 1
}

return 0

