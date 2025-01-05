. ./meta/meta.sh
((DEFENSE_VARIABLES[awk_bt_line_nb]++)) && return 0

# 匹配空行: ^[ \t]*$
# 抓取两个关键字之间的行，但是不包含边界
awk_bt_line_nb ()
{
    local regex1="$1" regex2="$2" deal_file="${3:--}"
    awk -v a="$regex1" -v b="$regex2" '$0 ~ a {flag=1; next} $0 ~ b {flag=0} flag' "${deal_file}"
}

return 0

