. ./meta/meta.sh
((DEFENSE_VARIABLES[str_tr_cr_to_space]++)) && return 0

# 1: 输入字符串
str_tr_cr_to_space ()
{
    local out_str=''
    out_str="${1//$'\r'/}"
    printf "%s" "${out_str//$'\n'/ }"
}

return 0

