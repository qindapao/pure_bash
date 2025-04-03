awk_bt_line.sh

. ./meta/meta.sh
((DEFENSE_VARIABLES[awk_bt_line]++)) && return 0

# 匹配空行: ^[ \t]*$
# 抓取两个关键字之间的行，并且包含上边界
awk_bt_line ()
{
    local regex1="$1" regex2="$2" deal_file="${3:--}"
    awk -v a="$regex1" -v b="$regex2" '$0 ~ a {flag=1} $0 ~ b {flag=0} flag || $0 ~ a' "${deal_file}"
}

return 0

