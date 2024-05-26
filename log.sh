. ./meta.sh
((DEFENSE_VARIABLES[log]++)) && return


# 第一次进来的时候记录当前环境中的所有变量名
mapfile -t _LOG_INIT_VARIABLES_NAME < <(compgen -A variable)


. ./str.sh
. ./array.sh
. ./date.sh

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
    local msg="${2} " i declare_str prt_str

    for((i=3;i<=$#;i++)) ; do
        # 如果是引用变量那么找到真正变量
        declare_str="$(declare -p "${!i}" 2>/dev/null)"
        prt_str="${!i}"
        while true ; do
            # :TODO: 确认后面的双引号或者单引号一定会出现
            if [[ "$declare_str" =~ ^declare\ [^\ ]*n[^\ ]*\ [^=]+=[\"\'](.+)[\"\']$ ]] ; then
                declare_str="$(declare -p "${BASH_REMATCH[1]}" 2>/dev/null)"
                prt_str+="->${BASH_REMATCH[1]}"
            else
                if [[ -n "$declare_str" ]] ; then
                    [[ "$prt_str" == "${!i}" ]] && prt_str='' || prt_str+=' '
                    declare_str="${prt_str}${declare_str:8}"
                else
                    declare_str="-- ${prt_str}=null"
                fi
                break
            fi
        done

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
        local -i func_index=1
        for((func_index=1;func_index<${#FUNCNAME[@]};func_index++)) ; do
            printf "%s\n" $'\t'"at ${FUNCNAME[func_index]}(${BASH_SOURCE[func_index]}:${BASH_LINENO[func_index-1]})"
            printf "%s\n" $'\t'"at ${FUNCNAME[func_index]}(${BASH_SOURCE[func_index]}:${BASH_LINENO[func_index-1]})" >>"$LOG_FILE_NAME"
        done

        # 把当前环境中所有变量的值记录到日志文件中(不打印)
        local -a all_vars_name_list
        mapfile -t all_vars_name_list < <(compgen -A variable)
        array_del_elements_dense all_vars_name_list "${_LOG_INIT_VARIABLES_NAME[@]}" 'log_type' 'is_need_break' 'msg' \
            'i' 'declare_str' 'prt_str' 'log_info' 'func_index' '_LOG_INIT_VARIABLES_NAME' 'LOG_ALLOW_BREAK' \
            'LOG_LEVEL' 'LOG_LEVEL_KIND'  '__str_bash_major_version' '__str_bash_minor_version' 'DEFENSE_VARIABLES' '__META'
        
        for i in "${all_vars_name_list[@]}" ; do
           declare -p "$i" >> "$LOG_FILE_NAME"
        done
    fi

    if ((LOG_ALLOW_BREAK&is_need_break)) ; then
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
    log_dbg 'd' "show params" params
}


log_get_all_vars_name ()
{
    local -n _dbg_get_all_vars_name_ref_array="$1"
    # declare -p 不跟变量打印所有变量和赋值表达式和值
    mapfile -t _dbg_get_all_vars_name_ref_array < <(compgen -A variable)
    array_del_elements_dense _dbg_get_all_vars_name_ref_array '_dbg_get_all_vars_name_ref_array'
}

# 因为我们有map函数,所以并不需要打印一系列变量的函数
# 打印一个变量(转换变量为可打印格式并且移除引号)
# 1: 变量名称字符串
# 2: 为高阶函数预留的index
# 3: 是否转换换行符为空格(默认转换)
# 4: 输出的分隔符(默认为空格)
log_prt_var ()
{
    local prt_var_info=''
    prt_var_info=$(declare -p "${1}" 2>/dev/null)
    local is_tr_cr_to_space="${3:-1}"
    local separator="${4:- }"
    
    if [[ -z "$prt_var_info" ]] ; then
        prt_var_info="${1}="
    elif [[ "$prt_var_info" =~ ^declare\ [-a-zA-Z]+\ ([^=]+=.+) ]] ; then
        prt_var_info="${BASH_REMATCH[1]}"

        ((is_tr_cr_to_space)) && { 
            prt_var_info="${prt_var_info//$'\n'/ }"
            prt_var_info="${prt_var_info//$'\r'/ }"
        }

        prt_var_info="${prt_var_info//\'/}"
        prt_var_info="${prt_var_info//\"/}"
    else
        prt_var_info="${1}="
    fi
    prt_var_info+="$separator"
    printf "%s" "$prt_var_info"
}

# 日志份数限制
# # 日志最多保留10份
# (
#     cd "${PLAT_LOG_DIR}/$1" || exit 1
#     declare -i keep_cnt=10

#     declare -a log_file_list=(*)
#     declare -a log_file_remain=(*)

#     if((${#log_file_list[@]}>keep_cnt)) ; then
#         IFS=$'\n' read -d "" -r -a log_file_remain < <(printf "%s\n" "${log_file_list[@]}" | sort -u | tail -n "$keep_cnt")

#         # 删除多余文件
#         for i in "${log_file_list[@]}" ; do
#             if [[ " ${log_file_remain[*]} " != *" ""$i"" "* ]] ; then
#                 rm -f ./"$i"
#             fi
#         done
#     fi
# )


