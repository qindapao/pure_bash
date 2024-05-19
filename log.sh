
((__LOG++)) && return

. ./str.sh
. ./date_utils.sh

# 0 debug 1 info 2 warning 3 error(打印三层记录)
LOG_LEVEL=0
LOG_ALLOW_BREAK=0
declare -a LOG_LEVEL_KIND=("d i w e" "i w e" "w e" "e")

LOG_FILE_NAME="test_log_$(date_log).log"

log_dbg ()
{
    local log_type=${1#*-}
    local is_need_break=0
    [[ "$1" == *'-'* ]] && is_need_break=${1%-*}
    [[ "${LOG_LEVEL_KIND[LOG_LEVEL]}" != *"$log_type"* ]] && return
    local msg="${2} " i declare_str
    for((i=3;i<=$#;i++)) ; do
        declare_str="$(declare -p "${!i}" 2>/dev/null)"
        [[ -n "$declare_str" ]] && declare_str=${declare_str:8} || declare_str="-- ${!i}=null"
        msg+="
        $declare_str "
    done
    local log_info
    log_info="[${log_type} ${BASH_SOURCE[1]} ${FUNCNAME[1]}(${BASH_LINENO[0]}):${FUNCNAME[2]}(${BASH_LINENO[1]}):${FUNCNAME[3]}(${BASH_LINENO[2]}) $(date_prt_t)] ${msg}"
    case "$log_type" in
        d) : 35 ;;
        i) : 32 ;;
        w) : 33 ;;
        e) : 31 ;;
    esac
    
    printf "\033[${_}m%s\033[0m\n" "$log_info"
    printf "%s\n" "$log_info" >>"$LOG_FILE_NAME"

    if [[ "e" == "$log_type" ]] ; then
        # :TODO: 待测试
        local -i func_index=1
        for((func_index=1;func_index<${#FUNCNAME[@]};func_index++)) ; do
            printf "%s\n" $'\t'"at ${FUNCNAME[func_index]}(${BASH_SOURCE[func_index]}:${BASH_LINENO[func_index-1]})"
            printf "%s\n" $'\t'"at ${FUNCNAME[func_index]}(${BASH_SOURCE[func_index]}:${BASH_LINENO[func_index-1]})" >>"$LOG_FILE_NAME"
        done
    fi

    if((LOG_ALLOW_BREAK&is_need_break)) ; then
        printf "\033[32m%s\033[0m\n" "you are in break mode,press Enter to Continue,Ctrl+c to End"
        #保存全部终端设置
        local savedstty=`stty -g 2>/dev/null`
        #禁止回显
        stty -echo 2>/dev/null
        dd if=/dev/tty bs=1 count=1 2>/dev/null
        #打开回显
        stty echo 2>/dev/null
        stty $savedstty 2>/dev/null
    fi

}

#-------------------------------------------------------------
# 显示所有参数
# 在函数中调用,可以显示所有位置入参
# show_params "${@}"
log_show_params ()
{
    local params=("$@")
    dbg_dbg 'd' "show params" params
}

# :TODO: 失败需要打印调用栈的函数

