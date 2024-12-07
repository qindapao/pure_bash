. ./meta/meta.sh
((DEFENSE_VARIABLES[log_s_dbg]++)) && return 0

. ./date/date_log.sh || return 1
. ./date/date_prt_t.sh || return 1
. ./array/array_dump.sh || return 1
. ./regex/regex_common.sh || return 1


# 日志函数的简化版本(不支持json数据的打印功能)
# 0 debug 1 info 2 warning 3 error(打印三层记录)
LOG_LEVEL=0
LOG_ALLOW_BREAK=0
declare -a LOG_LEVEL_KIND=("d i w e" "i w e" "w e" "e")

LOG_FILE_NAME="test_log_$(date_log).log"

# :TODO: 打印详细信息到系统日志的功能待验证

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
#    -d var1 var2
#    -d 后面的两个变量用于显示两个变量的差异,如果 -d var1 var1,那么显示变量在两次
#       调用上下文中的差异
#    全局变量 _log_s_dbg_bake_up_var_ 前缀用于保存变量的副本
#    :TODO: _log_s_dbg_bake_up_var_ 前缀的全局变量后续是否需要清理?
#
log_s_dbg ()
{
    local - ; set +xv
    if [[ "${#1}" == '1' ]] ; then
        local _log_s_dbg_log_type=${1}
        local -i _log_s_dbg_is_need_break=0
        local -i _log_s_dbg_is_need_print_to_std_out=1
    else
        local _log_s_dbg_log_type=${1:1:1}
        local -i _log_s_dbg_is_need_break=${1:0:1}
        local -i _log_s_dbg_is_need_print_to_std_out=${1:2:1}
    fi
    [[ "${LOG_LEVEL_KIND[LOG_LEVEL]}" != *"$_log_s_dbg_log_type"* ]] && return
    local _log_s_dbg_msg="${2} " _log_s_dbg_i _log_s_dbg_declare_str _log_s_dbg_prt_str
    local -i _log_s_dbg_is_need_diff_var=0
    local -a _log_s_dbg_diff_var_values=()
    local -a _log_s_dbg_diff_var_name=()
    local -A _log_s_dbg_has_printed_vars=()

    for((_log_s_dbg_i=3;_log_s_dbg_i<=$#;_log_s_dbg_i++)) ; do
        # 如果是引用变量那么找到真正变量
        # 这里不使用@a是因为,通过declare -p可以找到引用传递关系,@a只能显示最终真正变量的属性
        # 并且@a也只能bash4.4以及以上版本才能使用
        
        # 如果传入的变量不是合法标识符,直接忽略
        if [[ "${!_log_s_dbg_i}" =~ $REGEX_COMMON_VALID_VAR_NAME ]] ; then
            [[ "${_log_s_dbg_has_printed_vars[${!_log_s_dbg_i}]}" ]] || {
                _log_s_dbg_msg+=$'\n------------------------------------------------------------------'
            }
            # 记录完对比的变量后就需要清空
            ((${#_log_s_dbg_diff_var_values[@]}==2)) && {
                _log_s_dbg_is_need_diff_var=0
                _log_s_dbg_diff_var_values=()
                _log_s_dbg_diff_var_name=()
            }
        else
            if [[ "${!_log_s_dbg_i}" == '-d' ]] ; then
                _log_s_dbg_is_need_diff_var=1
                _log_s_dbg_diff_var_values=()
                _log_s_dbg_diff_var_name=()
            else
                [[ "${_log_s_dbg_has_printed_vars[${!_log_s_dbg_i}]}" ]] || {
                    _log_s_dbg_msg+=$'\n-  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -  - -'
                }
                _log_s_dbg_msg+=$'\n'
                _log_s_dbg_msg+="${!_log_s_dbg_i} is not a valid variable name!"
            fi
            continue
        fi

        array_dump "${!_log_s_dbg_i}" _log_s_dbg_declare_str

        # 读取变量的类型,如果发现是数组或者关联数组,使用结构体打印函数
        [[ "${_log_s_dbg_has_printed_vars[${!_log_s_dbg_i}]}" ]] || {
            _log_s_dbg_msg+=$'\n'
            _log_s_dbg_msg+="$_log_s_dbg_declare_str"
        }

        # 记录已经被打印过的变量名防止重复打印
        _log_s_dbg_has_printed_vars[${!_log_s_dbg_i}]=1

        # 判断是否要打印变量比对
        ((_log_s_dbg_is_need_diff_var)) && {
            _log_s_dbg_diff_var_values+=("$_log_s_dbg_declare_str")
            _log_s_dbg_diff_var_name+=("${!_log_s_dbg_i}") 
            if ((${#_log_s_dbg_diff_var_values[@]} == 2)) ; then
                if [[ "${_log_s_dbg_diff_var_name[0]}" == "${_log_s_dbg_diff_var_name[1]}" ]] &&
                   [[ ! -v "_log_s_dbg_bake_up_var_${_log_s_dbg_diff_var_name[0]}" ]] ; then
                    declare -g _log_s_dbg_bake_up_var_${_log_s_dbg_diff_var_name[0]}="${_log_s_dbg_diff_var_values[0]}"
                    continue
                fi

                # 显示两个变量的差异
                local _log_s_dbg_diff_file1=$(mktemp)
                local _log_s_dbg_diff_file2=$(mktemp)
                if [[ "${_log_s_dbg_diff_var_name[0]}" == "${_log_s_dbg_diff_var_name[1]}" ]] ; then
                    # 把上一次记录的值打印到这里来
                    local -n _log_s_dbg_last_var="_log_s_dbg_bake_up_var_${_log_s_dbg_diff_var_name[0]}"
                    printf "%s\n" "${_log_s_dbg_last_var}" > "$_log_s_dbg_diff_file1"
                    # 更新变量的值
                    _log_s_dbg_last_var=${_log_s_dbg_diff_var_values[0]}
                else
                    printf "%s\n" "${_log_s_dbg_diff_var_values[0]}" > "$_log_s_dbg_diff_file1"
                fi
                printf "%s\n" "${_log_s_dbg_diff_var_values[1]}" > "$_log_s_dbg_diff_file2"
                diff -y --color=auto "$_log_s_dbg_diff_file1" "$_log_s_dbg_diff_file2"
                _log_s_dbg_msg+=$'\n'
                _log_s_dbg_msg+='~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                _log_s_dbg_msg+=$'\n'
                # 直接打印到标准输出可以看到颜色
                _log_s_dbg_msg+=$(diff -y "$_log_s_dbg_diff_file1" "$_log_s_dbg_diff_file2")
                rm -f "$_log_s_dbg_diff_file1" "$_log_s_dbg_diff_file2"
            fi
        }
    done

    _log_s_dbg_msg+=$'\n=================================================================================='


    local _log_s_dbg_log_info
    _log_s_dbg_log_info="[${_log_s_dbg_log_type} ${BASH_SOURCE[1]} ${FUNCNAME[1]}(${BASH_LINENO[0]}):${FUNCNAME[2]}(${BASH_LINENO[1]}):${FUNCNAME[3]}(${BASH_LINENO[2]}) $(date_prt_t)] ${_log_s_dbg_msg}"
    local -A _log_s_dbg_color=([d]='36' [i]=32 [w]=33 [e]=35)
    local -A _log_s_dbg_other_effect=([d]='' [i]='' [w]='' [e]='')
    
    if ((_log_s_dbg_is_need_print_to_std_out)) ; then
        printf "\033[${_log_s_dbg_color[$_log_s_dbg_log_type]}m${_log_s_dbg_other_effect[$_log_s_dbg_log_type]}%s\033[0m\n" "$_log_s_dbg_log_info"
    fi
    printf "%s\n" "$_log_s_dbg_log_info" >>"$LOG_FILE_NAME"

    if [[ "$_log_s_dbg_log_type" == [ew] ]] ; then
        local -i _log_s_dbg_is_logger_exist=0 ; which logger &>/dev/null && _log_s_dbg_is_logger_exist=1
        ((_log_s_dbg_is_logger_exist)) && {
            local _log_s_dbg_log_tag_for_sys="[${_log_s_dbg_log_type} ${BASH_SOURCE[1]} ${FUNCNAME[1]}(${BASH_LINENO[0]}):${FUNCNAME[2]}(${BASH_LINENO[1]}):${FUNCNAME[3]}(${BASH_LINENO[2]}) $(date_prt_t)]"
            local _log_s_dbg_log_value_for_sys="$_log_s_dbg_msg"
            _log_s_dbg_log_value_for_sys+=$'\n'
            local _log_s_dbg_log_value_for_sys_tmp=''
        }

        local -i _log_s_dbg_func_index=1
        for((_log_s_dbg_func_index=1;_log_s_dbg_func_index<${#FUNCNAME[@]};_log_s_dbg_func_index++)) ; do
            if ((_log_s_dbg_is_need_print_to_std_out)) ; then
                printf "%s\n" $'\t'"${FUNCNAME[_log_s_dbg_func_index]}(${BASH_SOURCE[_log_s_dbg_func_index]}:${BASH_LINENO[_log_s_dbg_func_index-1]})"
            fi
            printf "%s\n" $'\t'"${FUNCNAME[_log_s_dbg_func_index]}(${BASH_SOURCE[_log_s_dbg_func_index]}:${BASH_LINENO[_log_s_dbg_func_index-1]})" >>"$LOG_FILE_NAME"
            ((_log_s_dbg_is_logger_exist)) && {
                printf -v _log_s_dbg_log_value_for_sys_tmp "%s\n" $'\t'"${FUNCNAME[_log_s_dbg_func_index]}(${BASH_SOURCE[_log_s_dbg_func_index]}:${BASH_LINENO[_log_s_dbg_func_index-1]})"
                _log_s_dbg_log_value_for_sys+="$_log_s_dbg_log_value_for_sys_tmp"
            }
        done
        ((_log_s_dbg_is_logger_exist)) && {
            logger --tag "$_log_s_dbg_log_tag_for_sys" "$_log_s_dbg_log_value_for_sys"
        }
    fi

    if ((LOG_ALLOW_BREAK&_log_s_dbg_is_need_break)) ; then
        if ((_log_s_dbg_is_need_print_to_std_out)) ; then
            printf "\033[32m%s\033[0m\n" "you are in break mode,press Enter to Continue,Ctrl+c to End"
        fi
        printf "\033[32m%s\033[0m\n" "you are in break mode,press Enter to Continue,Ctrl+c to End" >>"$LOG_FILE_NAME"
        #保存全部终端设置
        local _log_s_dbg_savedstty=`stty -g 2>/dev/null`
        #禁止回显
        stty -echo 2>/dev/null
        dd if=/dev/tty bs=1 count=1 2>/dev/null
        #打开回显
        printf "\033[32m%s\033[0m\n" "continue!"
        stty echo 2>/dev/null
        stty $_log_s_dbg_savedstty 2>/dev/null
    fi

    return 0
}

# 标准函数(打印到日志和标准输出,禁用断点)
alias lsdebug_p='log_s_dbg d'
alias lsinfo_p='log_s_dbg i'
alias lswarn_p='log_s_dbg w'
alias lserror_p='log_s_dbg e'

# 启用断点(打印日志到标准输出)
alias lsdebug_bp='log_s_dbg 1d1'
alias lsinfo_bp='log_s_dbg 1i1'
alias lswarn_bp='log_s_dbg 1w1'
alias lserror_bp='log_s_dbg 1e1'

alias lsdebug_pb='log_s_dbg 1d1'
alias lsinfo_pb='log_s_dbg 1i1'
alias lswarn_pb='log_s_dbg 1w1'
alias lserror_pb='log_s_dbg 1e1'

# 不启用断点(日志不打印到标准输出)
alias lsdebug='log_s_dbg 0d0'
alias lsinfo='log_s_dbg 0i0'
alias lswarn='log_s_dbg 0w0'
alias lserror='log_s_dbg 0e0'

# 启用断点(并且不打印到标准输出)
alias lsdebug_b='log_s_dbg 1d0'
alias lsinfo_b='log_s_dbg 1i0'
alias lswarn_b='log_s_dbg 1w0'
alias lserror_b='log_s_dbg 1e0'

return 0

