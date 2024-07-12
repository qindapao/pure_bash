. ./meta/meta.sh
((DEFENSE_VARIABLES[str_tr_cr_to_space]++)) && return 0

# 1: 输入字符串
str_tr_cr_to_space ()
{
    local out_str=''
    out_str="${2//$'\r'/}"
    printf "%s" "${out_str//$'\n'/ }"
}

alias str_tr_cr_to_space_s='str_tr_cr_to_space ""'

return 0

