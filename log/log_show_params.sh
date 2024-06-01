. ./meta/meta.sh
((DEFENSE_VARIABLES[log_show_params]++)) && return 0

. ./log/log_dbg.sh || return 1

# 显示所有参数
# 在函数中调用,可以显示所有位置入参
# show_params "${@}"
log_show_params ()
{
    local params=("$@")
    log_dbg 'd' "show params" params
}

return 0

