. ./meta/meta.sh
((DEFENSE_VARIABLES[log_dbg]++)) && return 0

. ./date/date_log.sh || return 1
. ./date/date_prt_t.sh || return 1
. ./json/json_dump.sh || return 1


# :TODO: 打印变量的功能暂时屏蔽掉
# :TODO: BASH_COMMAND 变量和 trap 结合使用?
# # 第一次进来的时候记录当前环境中的所有变量名
# mapfile -t _LOG_INIT_VARIABLES_NAME < <(compgen -A variable)

# 0 debug 1 info 2 warning 3 error(打印三层记录)
LOG_LEVEL=0
LOG_ALLOW_BREAK=0
declare -a LOG_LEVEL_KIND=("d i w e" "i w e" "w e" "e")

LOG_FILE_NAME="test_log_$(date_log).log"

# 参数说明
# 1: 调试级别(两种情况)
#   裸字母
#       d i w e: 对应调试级别，并且不启动断点,打印到标准输出
#   字母前后带数字(第一个数字表示是否启用断点,第二个表示是否打印到标准输出)
#       1d1: 启用断点并且打印到标准输出 
#       0d0: 不启用断点并且不打印到标签输出
#       0d1: 不启用断点并且打印到标准输出(裸字母的情况)
#       1d0: 启动断点并且不打印到标准输出
#           如果是调试xx=$(yy) 这种调用里面的函数必须需要这样打印日志
#           调试的时候把日志文件用tail -f xx.log的形式打开根据调试提示敲终端
#           :TODO: 这种情况待测试
# 2: 需要直接打印的字符串
# 3~@:
#    需要打印的变量
log_dbg ()
{
    disable_xv
    if [[ "${#1}" == '1' ]] ; then
        local _log_dbg_log_type=${1}
        local -i _log_dbg_is_need_break=0
        local -i _log_dbg_is_need_print_to_std_out=1
    else
        local _log_dbg_log_type=${1:1:1}
        local -i _log_dbg_is_need_break=${1:0:1}
        local -i _log_dbg_is_need_print_to_std_out=${1:2:1}
    fi
    [[ "${LOG_LEVEL_KIND[LOG_LEVEL]}" != *"$_log_dbg_log_type"* ]] && return
    local _log_dbg_msg="${2} " _log_dbg_i _log_dbg_declare_str _log_dbg_prt_str

    for((_log_dbg_i=3;_log_dbg_i<=$#;_log_dbg_i++)) ; do
        # 如果是引用变量那么找到真正变量
        # 这里不使用@a是因为,通过declare -p可以找到引用传递关系,@a只能显示最终真正变量的属性
        # 并且@a也只能bash4.4以及以上版本才能使用
        
        _log_dbg_msg+=$'\n-  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -'

        # 如果传入的变量不是合法标识符,直接忽略
        [[ "${!_log_dbg_i}" =~ ^[a-zA-Z_]+[a-zA-Z0-9_]*$ ]] || {
            _log_dbg_msg+=$'\n'
            _log_dbg_msg+="${!_log_dbg_i} is not a valid variable name!"
            continue
        }

        _log_dbg_declare_str="$(declare -p "${!_log_dbg_i}" 2>/dev/null)"
        _log_dbg_prt_str="${!_log_dbg_i}"
        
        local -n _log_dbg_declare_arr_ref="${!_log_dbg_i}"

        while true ; do
            # :TODO: 确认后面的双引号或者单引号一定会出现
            if [[ "$_log_dbg_declare_str" =~ ^declare\ [^\ ]*n[^\ ]*\ [^=]+=[\"\'](.+)[\"\']$ ]] ; then
                _log_dbg_declare_str="$(declare -p "${BASH_REMATCH[1]}" 2>/dev/null)"
                _log_dbg_prt_str+="->${BASH_REMATCH[1]}"
            else
                # :TODO: 这里的逻辑有点绕,需要优化和简化
                if [[ -n "$_log_dbg_declare_str" ]] ; then
                    if [[ "${_log_dbg_declare_arr_ref@a}" == *[aA]* ]] ; then
                        # 相等是没有引用变量的情况
                        if [[ "$_log_dbg_prt_str" == "${!_log_dbg_i}" ]] ; then
                            _log_dbg_prt_str=''
                        else
                            _log_dbg_prt_str+=$'\n'
                        fi
                        _log_dbg_declare_str="$_log_dbg_prt_str"
                        # 横向打印原始字符串,更方便阅读(但是换行的时候就比较难看)
                        # :TODO: 如何打印最合适啊?
                        _log_dbg_declare_str+=$(json_dump_ho "${!_log_dbg_i}")
                    else
                        # 相等是没有引用变量的情况
                        [[ "$_log_dbg_prt_str" == "${!_log_dbg_i}" ]] && _log_dbg_prt_str='' || _log_dbg_prt_str+=' '
                        _log_dbg_declare_str="${_log_dbg_prt_str}${_log_dbg_declare_str:8}"
                    fi
                else
                    _log_dbg_declare_str="-- ${_log_dbg_prt_str}=null"
                fi
                break
            fi
        done

        # 读取变量的类型,如果发现是数组或者关联数组,使用结构体打印函数
        _log_dbg_msg+=$'\n'
        _log_dbg_msg+="$_log_dbg_declare_str"
    done

    _log_dbg_msg+=$'\n----------------------------------------------------------------------------------'

    local _log_dbg_log_info
    _log_dbg_log_info="[${_log_dbg_log_type} ${BASH_SOURCE[1]} ${FUNCNAME[1]}(${BASH_LINENO[0]}):${FUNCNAME[2]}(${BASH_LINENO[1]}):${FUNCNAME[3]}(${BASH_LINENO[2]}) $(date_prt_t)] ${_log_dbg_msg}"
    local -A _log_dbg_color=([d]='36' [i]=32 [w]=33 [e]=35)
    local -A _log_dbg_other_effect=([d]='' [i]='' [w]='' [e]='')
    
    if ((_log_dbg_is_need_print_to_std_out)) ; then
        printf "\033[${_log_dbg_color[$_log_dbg_log_type]}m${_log_dbg_other_effect[$_log_dbg_log_type]}%s\033[0m\n" "$_log_dbg_log_info"
    fi
    printf "%s\n" "$_log_dbg_log_info" >>"$LOG_FILE_NAME"

    if [[ "$_log_dbg_log_type" == [ew] ]] ; then
        local -i _log_dbg_func_index=1
        for((_log_dbg_func_index=1;_log_dbg_func_index<${#FUNCNAME[@]};_log_dbg_func_index++)) ; do
            if ((_log_dbg_is_need_print_to_std_out)) ; then
                printf "%s\n" $'\t'"${FUNCNAME[_log_dbg_func_index]}(${BASH_SOURCE[_log_dbg_func_index]}:${BASH_LINENO[_log_dbg_func_index-1]})"
            fi
            printf "%s\n" $'\t'"${FUNCNAME[_log_dbg_func_index]}(${BASH_SOURCE[_log_dbg_func_index]}:${BASH_LINENO[_log_dbg_func_index-1]})" >>"$LOG_FILE_NAME"
        done

        # # 把当前环境中所有变量的值记录到日志文件中(不打印)
        # local -a _log_dbg_all_vars_name_list
        # mapfile -t _log_dbg_all_vars_name_list < <(compgen -A variable)
        # array_del_elements_dense _log_dbg_all_vars_name_list "${_LOG_INIT_VARIABLES_NAME[@]}" '_log_dbg_log_type' '_log_dbg_is_need_break' '_log_dbg_msg' \
        #     '_log_dbg_i' '_log_dbg_declare_str' '_log_dbg_prt_str' '_log_dbg_log_info' '_log_dbg_func_index' '_LOG_INIT_VARIABLES_NAME' 'LOG_ALLOW_BREAK' \
        #     'LOG_LEVEL' 'LOG_LEVEL_KIND'  '__META_BASH_VERSION' 'DEFENSE_VARIABLES' '__META' '_log_dbg_color' '_log_dbg_other_effect'
        
        # echo "==============ALL VARIABLE===================" >>"$LOG_FILE_NAME"
        # for _log_dbg_i in "${_log_dbg_all_vars_name_list[@]}" ; do
        #     :TODO: 下面这个写法有风险,调用函数 atom_identify_data_type 保险
        #     if [[ "${!_log_dbg_i@a}" == *[aA]* ]] ; then
        #         json_dump_hq "${_log_dbg_i}" >> "$LOG_FILE_NAME" 
        #     else
        #         declare -p "$_log_dbg_i" >> "$LOG_FILE_NAME"
        #     fi
        #     echo '-  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -' >>"$LOG_FILE_NAME"
        # done
    fi

    if ((LOG_ALLOW_BREAK&_log_dbg_is_need_break)) ; then
        if ((_log_dbg_is_need_print_to_std_out)) ; then
            printf "\033[32m%s\033[0m\n" "you are in break mode,press Enter to Continue,Ctrl+c to End"
        fi
        printf "\033[32m%s\033[0m\n" "you are in break mode,press Enter to Continue,Ctrl+c to End" >>"$LOG_FILE_NAME"
        #保存全部终端设置
        local _log_dbg_savedstty=`stty -g 2>/dev/null`
        #禁止回显
        stty -echo 2>/dev/null
        dd if=/dev/tty bs=1 count=1 2>/dev/null
        #打开回显
        printf "\033[32m%s\033[0m\n" "continue!"
        stty echo 2>/dev/null
        stty $_log_dbg_savedstty 2>/dev/null
    fi

    return 0
}

# 标准函数(打印到日志和标准输出,禁用断点)
alias ldebug_p='log_dbg d'
alias linfo_p='log_dbg i'
alias lwarn_p='log_dbg w'
alias lerror_p='log_dbg e'

# 启用断点(打印日志到标准输出)
alias ldebug_bp='log_dbg 1d1'
alias linfo_bp='log_dbg 1i1'
alias lwarn_bp='log_dbg 1w1'
alias lerror_bp='log_dbg 1e1'

alias ldebug_pb='log_dbg 1d1'
alias linfo_pb='log_dbg 1i1'
alias lwarn_pb='log_dbg 1w1'
alias lerror_pb='log_dbg 1e1'

# 不启用断点(日志不打印到标准输出)
alias ldebug='log_dbg 0d0'
alias linfo='log_dbg 0i0'
alias lwarn='log_dbg 0w0'
alias lerror='log_dbg 0e0'

# 启用断点(并且不打印到标准输出)
alias ldebug_b='log_dbg 1d0'
alias linfo_b='log_dbg 1i0'
alias lwarn_b='log_dbg 1w0'
alias lerror_b='log_dbg 1e0'

return 0

