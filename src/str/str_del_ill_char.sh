. ./meta/meta.sh
((DEFENSE_VARIABLES[str_del_ill_char]++)) && return 0

# 1: 需要删除xml不识别的字符的原始字符串的名字
str_del_ill_char ()
{
    local _str_del_ill_char_valid_chars=''
    printf -v _str_del_ill_char_valid_chars '\\%o' {32..37} {39..59} 61 {63..126}
    printf -v _str_del_ill_char_valid_chars '%b' "$_str_del_ill_char_valid_chars"
    printf -v "$1" "%s" "${!1//[^"$_str_del_ill_char_valid_chars"]/}"
}

return 0

