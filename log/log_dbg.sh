. ./meta/meta.sh
((DEFENSE_VARIABLES[log_dbg]++)) && return 0

. ./array/array_del_elements_dense.sh || return 1
. ./date/date_log.sh || return 1
. ./date/date_prt_t.sh || return 1


# 第一次进来的时候记录当前环境中的所有变量名
mapfile -t _LOG_INIT_VARIABLES_NAME < <(compgen -A variable)

# 0 debug 1 info 2 warning 3 error(打印三层记录)
LOG_LEVEL=0
LOG_ALLOW_BREAK=0
declare -a LOG_LEVEL_KIND=("d i w e" "i w e" "w e" "e")

LOG_FILE_NAME="test_log_$(date_log).log"

log_dbg ()
{
    local -i _log_dbg_is_set_x=0
    [[ $- == *x* ]] && ((_log_dbg_is_set_x++)) && set +x

    local _log_dbg_log_type=${1#*-}
    local _log_dbg_is_need_break=0
    [[ "$1" == *'-'* ]] && _log_dbg_is_need_break=${1%-*}
    [[ "${LOG_LEVEL_KIND[LOG_LEVEL]}" != *"$_log_dbg_log_type"* ]] && return
    local _log_dbg_msg="${2} " _log_dbg_i _log_dbg_declare_str _log_dbg_prt_str

    for((_log_dbg_i=3;_log_dbg_i<=$#;_log_dbg_i++)) ; do
        # 如果是引用变量那么找到真正变量
        _log_dbg_declare_str="$(declare -p "${!_log_dbg_i}" 2>/dev/null)"
        _log_dbg_prt_str="${!_log_dbg_i}"
        while true ; do
            # :TODO: 确认后面的双引号或者单引号一定会出现
            if [[ "$_log_dbg_declare_str" =~ ^declare\ [^\ ]*n[^\ ]*\ [^=]+=[\"\'](.+)[\"\']$ ]] ; then
                _log_dbg_declare_str="$(declare -p "${BASH_REMATCH[1]}" 2>/dev/null)"
                _log_dbg_prt_str+="->${BASH_REMATCH[1]}"
            else
                if [[ -n "$_log_dbg_declare_str" ]] ; then
                    [[ "$_log_dbg_prt_str" == "${!_log_dbg_i}" ]] && _log_dbg_prt_str='' || _log_dbg_prt_str+=' '
                    _log_dbg_declare_str="${_log_dbg_prt_str}${_log_dbg_declare_str:8}"
                else
                    _log_dbg_declare_str="-- ${_log_dbg_prt_str}=null"
                fi
                break
            fi
        done

        _log_dbg_msg+="
        $_log_dbg_declare_str "
    done
    local _log_dbg_log_info
    _log_dbg_log_info="[${_log_dbg_log_type} ${BASH_SOURCE[1]} ${FUNCNAME[1]}(${BASH_LINENO[0]}):${FUNCNAME[2]}(${BASH_LINENO[1]}):${FUNCNAME[3]}(${BASH_LINENO[2]}) $(date_prt_t)] ${_log_dbg_msg}"
    case "$_log_dbg_log_type" in
        d) : 35 ;;
        i) : 32 ;;
        w) : 33 ;;
        e) : 31 ;;
    esac
    
    printf "\033[${_}m%s\033[0m\n" "$_log_dbg_log_info"
    printf "%s\n" "$_log_dbg_log_info" >>"$LOG_FILE_NAME"

    if [[ "e" == "$_log_dbg_log_type" ]] ; then
        local -i _log_dbg_func_index=1
        for((_log_dbg_func_index=1;_log_dbg_func_index<${#FUNCNAME[@]};_log_dbg_func_index++)) ; do
            printf "%s\n" $'\t'"at ${FUNCNAME[_log_dbg_func_index]}(${BASH_SOURCE[_log_dbg_func_index]}:${BASH_LINENO[_log_dbg_func_index-1]})"
            printf "%s\n" $'\t'"at ${FUNCNAME[_log_dbg_func_index]}(${BASH_SOURCE[_log_dbg_func_index]}:${BASH_LINENO[_log_dbg_func_index-1]})" >>"$LOG_FILE_NAME"
        done

        # 把当前环境中所有变量的值记录到日志文件中(不打印)
        local -a _log_dbg_all_vars_name_list
        mapfile -t _log_dbg_all_vars_name_list < <(compgen -A variable)
        array_del_elements_dense _log_dbg_all_vars_name_list "${_LOG_INIT_VARIABLES_NAME[@]}" '_log_dbg_log_type' '_log_dbg_is_need_break' '_log_dbg_msg' \
            '_log_dbg_i' '_log_dbg_declare_str' '_log_dbg_prt_str' '_log_dbg_log_info' '_log_dbg_func_index' '_LOG_INIT_VARIABLES_NAME' 'LOG_ALLOW_BREAK' \
            'LOG_LEVEL' 'LOG_LEVEL_KIND'  '__date_vars_bash_major_version' '__date_vars_bash_minor_version' 'DEFENSE_VARIABLES' '__META'
        
        for _log_dbg_i in "${_log_dbg_all_vars_name_list[@]}" ; do
           declare -p "$_log_dbg_i" >> "$LOG_FILE_NAME"
        done
    fi

    if ((LOG_ALLOW_BREAK&_log_dbg_is_need_break)) ; then
        printf "\033[32m%s\033[0m\n" "you are in break mode,press Enter to Continue,Ctrl+c to End"
        #保存全部终端设置
        local _log_dbg_savedstty=`stty -g 2>/dev/null`
        #禁止回显
        stty -echo 2>/dev/null
        dd if=/dev/tty bs=1 count=1 2>/dev/null
        #打开回显
        stty echo 2>/dev/null
        stty $_log_dbg_savedstty 2>/dev/null
    fi

    ((_log_dbg_is_set_x)) && set -x
}

return 0

