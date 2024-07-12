. ./meta/meta.sh
((DEFENSE_VARIABLES[trap_exit]++)) && return 0

. ./date/date_log.sh || return 1
. ./date/date_prt_t.sh || return 1
. ./trap/trap_global_vars.sh || return 1
. ./trap/trap_local_vars.sh || return 1

TRAP_EXIT_FILE="trap_exit_$(date_log).log"

# :TODO: 打印的末级行号是不准确的
# 捕捉脚本的退出信号,并设置错误处理函数
# 最后上报的命令不是错误的命令，只是最后执行的命令
trap_exit ()
{
    disable_xv
    local _trap_exit_last_command_ext_code=$?
    local _trap_exit_pipestatus=$1 _trap_exit_lineno=$2 _trap_exit_bash_command=$3

    local _trap_exit_func_index
    local _trap_exit_now_time=''
    date_prt_t _trap_exit_now_time
    
    # 1. 打印执行失败的命令的时间和具体的命令
    printf "%s\n" "=======================================" >>"$TRAP_EXIT_FILE"
    # 数组中首尾是假的,已经删除,第一个行号从DEBUG陷阱过来
    local -a _trap_exit_lineno_stack=("${_trap_exit_lineno}" "${BASH_LINENO[@]:1:${#BASH_LINENO[@]}-2}")
    printf "%s\n" "PREVIOUS CMD:${_trap_exit_bash_command}" >>"$TRAP_EXIT_FILE"
    printf "%s\n" "BASH_LINENO:${_trap_exit_lineno_stack[*]}" >>"$TRAP_EXIT_FILE"
    printf "%s\n" "RETURN CODE:${_trap_exit_last_command_ext_code}" >>"$TRAP_EXIT_FILE"
    printf "%s\n" "PIPESTATUS:${_trap_exit_pipestatus}" >>"$TRAP_EXIT_FILE"
    printf "%s\n" "FUNC STACK =>" >>"$TRAP_EXIT_FILE" 

    for((_trap_exit_func_index=1;_trap_exit_func_index<${#FUNCNAME[@]};_trap_exit_func_index++)) ; do
        printf "%s\n" $'\t'"at ${FUNCNAME[_trap_exit_func_index]}(${BASH_SOURCE[_trap_exit_func_index]}:${_trap_exit_lineno_stack[_trap_exit_func_index-1]})" >>"$TRAP_EXIT_FILE"
    done

    # 打印需要打印的变量的值
    printf "%s\n" "..........GLOBAL..VARS.................." >>"$TRAP_EXIT_FILE"
    local _trap_exit_var
    for _trap_exit_var in "${!TRAP_GLOBAL_VARS[@]}" ; do
        # 只是简单的打印,结构体的打印就不在这里处理了,反正可以还原(这里为了效率)
        declare -p "$_trap_exit_var" >> "$TRAP_EXIT_FILE" 2>&1
    done

    printf "%s\n" "..........local..vars.................." >>"$TRAP_EXIT_FILE"

    for _trap_exit_var in "${!TRAP_LOCAL_VARS[@]}" ; do
        # 只是简单的打印,结构体的打印就不在这里处理了,反正可以还原(这里为了效率)
        declare -p "$_trap_exit_var" >> "$TRAP_EXIT_FILE" 2>&1
    done

    return 0
}

return 0

