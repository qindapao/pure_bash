. ./meta/meta.sh
((DEFENSE_VARIABLES[log_p_l]++)) && return 0

# 用于打印长字符串到标准输出,输出换行符
log_p_l ()
{
    local IFS=
    printf "%s\n" "${*}"
}

return 0

