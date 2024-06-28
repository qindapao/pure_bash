. ./meta/meta.sh
((DEFENSE_VARIABLES[trap_err]++)) && return 0

# mm=$(echo '' | echo '' | echo '' | echo '' | grep foo | grep xx | echo '')
# :TODO: 上面的命令最终结果是成功,所以err陷阱无法捕捉的,即使中间管道命令有失败
# 陷阱函数中千万不能打印东西到标准输出或者错误输出,不然可能会被正常脚本代码捕捉
# 子shell中继承陷阱(set函数中设置)
# set -T 子shell 中 继承RETURN 和 DEBUG 陷阱
# set -E

. ./date/date_log.sh || return 1
. ./date/date_prt_t.sh || return 1
. ./trap/trap_global_vars.sh || return 1
. ./trap/trap_local_vars.sh || return 1


# :TODO: set -xv 这两个选项结合起来调试威力更大
# :TODO: 遇到错误先执行trap函数,然后转而执行后面的代码,我们甚至可以在这里设置断点!
# :TODO: 某些变量的打印并不准确
# :TODO: 打印变量的功能暂时屏蔽掉
# # 第一次进来的时候记录当前环境中的所有变量名
# mapfile -t _LOG_INIT_VARIABLES_NAME < <(compgen -A variable)

# :TODO: 说明如果异步的子进程继承了陷阱,那么最好子脚本(或者子shell)中的TRAP_ERR_FILE变量最好重新命名
# 可以跟上进程的pid或者是别的独立标识
TRAP_ERR_FILE="trap_err_$(date_log).log"

# 捕捉脚本中的错误信号,并设置错误处理函数
# :TODO: 注意:如果打开了退出陷阱,那么最后一次的错误可能是误报的,报的就是最后一次执行的
# 指令而已，不一定是错误
trap_err ()
{
    disable_xv
    local _trap_err_last_command_ext_code=$?
    local _trap_err_bash_command="${2}"
    local _trap_err_pipestatus="${1}"
    local _trap_err_now_time=''
    date_prt_t _trap_err_now_time

    local _trap_err_func_index
    
    # 1. 打印执行失败的命令的时间和具体的命令
    printf "%s\n" "=======================================" >>"$TRAP_ERR_FILE"
    printf "%s\n" "${_trap_err_now_time} last fail command =>" >>"$TRAP_ERR_FILE"
    printf "%s\n" "${_trap_err_bash_command}" >>"$TRAP_ERR_FILE"
    printf "%s\n" "---------------------------------------" >>"$TRAP_ERR_FILE"
    printf "%s\n" "BASH_LINENO:${BASH_LINENO[*]}" >>"$TRAP_ERR_FILE"
    printf "%s\n" "RETURN CODE:${_trap_err_last_command_ext_code}" >>"$TRAP_ERR_FILE"
    printf "%s\n" "PIPESTATUS:${_trap_err_pipestatus}" >>"$TRAP_ERR_FILE"
    printf "%s\n" "FUNC STACK =>" >>"$TRAP_ERR_FILE" 

    for((_trap_err_func_index=1;_trap_err_func_index<${#FUNCNAME[@]};_trap_err_func_index++)) ; do
        printf "%s\n" $'\t'"at ${FUNCNAME[_trap_err_func_index]}(${BASH_SOURCE[_trap_err_func_index]}:${BASH_LINENO[_trap_err_func_index-1]})" >>"$TRAP_ERR_FILE"
    done

    # 打印需要打印的变量的值
    printf "%s\n" "..........GLOBAL..VARS.................." >>"$TRAP_ERR_FILE"
    local _trap_err_var
    # :TODO: 这里是否需要排序?(只是为了调试没有必要,排序浪费时间)
    for _trap_err_var in "${!TRAP_GLOBAL_VARS[@]}" ; do
        # 只是简单的打印,结构体的打印就不在这里处理了,反正可以还原(这里为了效率)
        # :TODO: 这里无法打印引用变量的值,是否要打印${var[@]@A}?
        declare -p "$_trap_err_var" >> "$TRAP_ERR_FILE" 2>&1
    done
    printf "%s\n" "..........local..vars.................." >>"$TRAP_ERR_FILE"
    for _trap_err_var in "${!TRAP_LOCAL_VARS[@]}" ; do
        # 只是简单的打印,结构体的打印就不在这里处理了,反正可以还原(这里为了效率)
        declare -p "$_trap_err_var" >> "$TRAP_ERR_FILE" 2>&1
    done

    return 0
}

return 0

