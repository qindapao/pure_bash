. ./meta/meta.sh
((DEFENSE_VARIABLES[awk_add_separator]++)) && return 0

# 匹配空行: ^[ \t]*$
# 抓取两个关键字之间的行，并且把下边界变成固定的分隔符，上边界保留
awk_add_separator ()
{
    local regex1="$1" regex2="$2" separator="$3" deal_file="${4:--}"
    awk -v a="$regex1" -v b="$regex2" -v c="$separator" \
        '$0 ~ a {flag=1} $0 ~ b {if(flag==1) {print c} ; flag=0} flag \
        || $0 ~ a' "${deal_file}"
}

return 0

