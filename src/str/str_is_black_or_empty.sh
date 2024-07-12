. ./meta/meta.sh
((DEFENSE_VARIABLES[str_is_black_or_empty]++)) && return 0

# 判断一个字符串是否只包含空白字符或者是空字符串
str_is_black_or_empty ()
{
    # 陷阱中$_值不准确,所以放弃使用:这种形式
    # : "${2#"${2%%[![:space:]]*}"}"
    local tmp_str="${2#"${2%%[![:space:]]*}"}"
    local deal_str="${tmp_str%"${_##*[![:space:]]}"}"
    
    [[ -z "$deal_str" ]]
}

alias str_is_black_or_empty_s='str_is_black_or_empty ""'

return 0

