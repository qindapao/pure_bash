. ./meta/meta.sh
((DEFENSE_VARIABLES[str_del_xml_ill_char]++)) && return 0

# 1: 需要删除xml不识别的字符的原始字符串的名字(&<>)
# :TODO: 引号要考虑吗?
str_del_xml_ill_char ()
{
    case "$#" in
    0)
    local std_in_str=
    IFS= read -d '' -r std_in_str || true
    local valid_chars=''
    printf -v valid_chars '\\%o' {32..37} {39..59} 61 {63..126}
    printf -v valid_chars '%b' "$valid_chars"
    printf "%s" "${std_in_str//[^"$valid_chars"]/}"
    ;;
    *)
    local ill$1
    printf -v "ill$1" '\\%o' {32..37} {39..59} 61 {63..126}
    eval -- 'printf -v "ill$1" '\''%b'\'' "$ill'$1'"'
    ;;&
        1)
        eval -- 'printf -v '$1' "%s" "${!1//[^"$ill'$1'"]/}"'
        ;;
        *)
        eval -- $1[\$2]='${3//[^"$ill'$1'"]/}'
        ;;
    esac
}

return 0

