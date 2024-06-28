#!/bin/bash
#========================
# 作者:
# 使用方法:
#     # 删除所有的日志文件只保留最后一份
#     export __logdir=$(pwd)
#     rm -f $(ls -l | grep -E "*_xx_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}.debug" | awk '{print $NF}')
#     export __logfile=xx_$(date +"%y_%m_%d_%H_%M_%S").debug
#     
#     # 如果是主脚本的日志,在初始化的时候一并删除
#     rm -f $(ls -l | grep -E "xx_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}.debug" | awk '{print $NF}')
#     
#     # 在导入debug库之前需要先删除日志文件(如果日志文件不带日期,那么使用这种即可)
#     rm -rf *_${__logfile}
#     
#     source ./bash_debuger.sh
#     
#     __loglevel=0
#     __breakpointflag=1
#     __xlogdebugflag=0
#     
#     
# 版本:v1.01
#   1. 增加文件变更功能
#   2. 增加变量变更和显示功能
# 版本:v1.02
#   1. 增加日志函数的简化版本lg_dbug,在同一个装备脚本中lg_dbug和log_debug不要同时使用
#   2. 清理中间过程日志文件的动作放到主脚本中进行,不在日志脚本中进行清理,防止子脚本多次调用导致日志丢失
# 版本:v1.03
#   1. 简单函数中增加单个变量打印功能
#   2. 日志函数拆分为4个,满足不同的日志定位需求
#========================

__loglevel=4
# __logfile 作为环境变量从外部导入
# __logfile=key_log_$(date +"%y_%m_%d_%H_%M_%S").debug
__breakpointflag=0
__xlogdebugflag=0

#查看变量值的初始文件,所有相同点都会过滤
__var_init_file="${__logdir}/__var_init_${__logfile}"
#查看变量值的文件,当前脚本当前时刻所有变量会导入
__var_cur_file="${__logdir}/__var_cur_file_${__logfile}"
__var_cur_file_tmp2="${__logdir}/_tmp2__var_cur_file_${__logfile}"
__var_cur_file_tmp="${__logdir}/__var_cur_file_tmp_${__logfile}"
__var_cur_file_deal="${__logdir}/__var_cur_file_deal_${__logfile}"

__var_cur_file_deal_again="${__logdir}/__var_cur_file_deal_again_${__logfile}"
__var_cur_file_deal_out_put_temp="${__logdir}/__var_cur_file_deal_out_put_temp_${__logfile}"


#文件列表初始化
__all_file_list_init="${__logdir}/__file_list_init_${__logfile}"
__all_file_list_now="${__logdir}/__file_list_now_${__logfile}"
__all_file_list_change="${__logdir}/__file_list_change_${__logfile}"


#保存初始变量
declare -p >${__var_init_file}
#初始化中需要删除的行
sed -i '/declare -a BASH_LINENO=/d' ${__var_init_file}
sed -i '/declare -a BASH_SOURCE=/d' ${__var_init_file}
sed -i '/declare -a FUNCNAME=/d' ${__var_init_file}
sed -i '/declare -i LINENO=/d' ${__var_init_file}
sed -i '/declare -- __loglevel=/d' ${__var_init_file}
sed -i '/declare -- __logfile=/d' ${__var_init_file}
sed -i '/declare -- __logdir=/d' ${__var_init_file}
sed -i '/declare -- __breakpointflag=/d' ${__var_init_file}
sed -i '/declare -- __xlogdebugflag=/d' ${__var_init_file}
sed -i '/declare -- __var_init_file=/d' ${__var_init_file}
sed -i '/declare -- __var_cur_file=/d' ${__var_init_file}
sed -i '/declare -- __var_cur_file_tmp=/d' ${__var_init_file}
sed -i '/declare -a BASH_ARGC=/d' ${__var_init_file}
sed -i '/declare -a BASH_ARGV=/d' ${__var_init_file}
sed -i '/declare -- _=/d' ${__var_init_file}


#记录测试过程中所有详细日志
rm -f test_log.log
rm -f test_log.bz2
rm -f $__logfile

#设置调试开关,显示所有执行命令
if [ "${ITESTINSIDE_TU_DEBUG_FLAG}" = "TRUE" ] ; then
    #设置PS4环境变量，便于调试
    export PS4='{${BASH_SOURCE[0]##*/}:${LINENO}:${BASH_LINENO}:${FUNCNAME[0]}<${FUNCNAME[1]}|`date +'%H%M%S'`}'
    set -x
    exec 100>&1
    exec 1>>test_log.log
    exec 2>&1
fi

#---------------------------------------------------------------------------------------------------
# FUNCTION NAME: log_debug
#   DESCRIPTION: 日志打印函数,执行一次打印大概0.018s,对效率要求很高的脚本不用使用调试函数
#                或者是把日志级别设置为大于3的数
#                TODO:后续升级可以把当前运行的文件和文件调用树打印出来(作用并不大,暂时不实现)
#                     还可以升级支持自定义命令的输入(作用并不大,暂时不实现)
#     PARAMETER: out:
#                in:
#                   __loglevel:全局变量,打印机别0 1 2 3,数字越小打印机别越高,超过3将屏蔽所有日志打印和所有断点
#                   __logfile:全局变量,需要保存的日志文件名
#                   __breakpointflag:全局变量,断点标志,如果设置为1,表示使能断点功能
#                   __xlogdebugflag:全局标量,调试标志,如果设置为1,表示使能调试功能
#                   1=>日志类别
#                      debug info warn error 正常的打印信息
#                      b-debug b-info b-warn b-error 表示需要设置断点
#                      x-debug x-info x-warn x-error 表示需要执行调试命令
#                      b-x-debug b-x-info b-x-warn b-x-error 表示断点且执行调试命令
#                      __breakpointflag全局变量为1的时候使能断点功能,否则只打印日志信息,不中断
#                      断点设置的情况下,终端点击回车继续往下执行,ctrl+C中断当前脚本
#                      
#                      __xlogdebugflag全局变量为1的时候使能调试功能,否则只执行别的操作
#                   2=>当前日志是否需要追加系统日志文件是否需要打印到串口
#                      n: 不需要处理
#                      sc: 需要打印到串口(带颜色字符)
#                      sb: 需要打印到串口(不带颜色字符)
#                      m: 需要输出到系统messages
#                      sc-m:打印到串口(带颜色字符),同时输出到messages
#                      sb-m:打印到串口(不带颜色字符),同时输出到messages
#                         v:把当前变量的值打印到日志文件中
#                         f:文件的变更列表也会打印出来
#                        vf:变量和文件都打印到日志文件中
#                    no-var:断点的时候变量不显示出来,根据调试指令来显示
#                           注意下这个模式只能在断点模式下使用
#                   3=>需要打印的详细信息
#                   4~@=>只有当调试模式的时候第四个参数需要传递进来(一般都是一个调试函数)
#        RETRUN: 成功=>0
#                失败=>1
#UPDATE HISTORY: xx 周四, 十月 24 19 02:36:09 下午
#                   新建
#---------------------------------------------------------------------------------------------------
log_debug ()
{
    local - ; set +xv
    local __logtype=${1##*-}
    local __break_flag=${1%-*}
    case "$__loglevel" in
        0)
            :
            ;;
        1)
            if [ "${__logtype}" = "debug" ] ; then
                return 0
            fi
            ;;
        2)
            if [ "${__logtype}" = "debug" -o "${__logtype}" = "info" ] ; then
                return 0
            fi
            ;;
        3)
            if [ "${__logtype}" != "error" ] ; then
                return 0
            fi
            ;;
        *)
            return 1
            ;;
    esac
    
    local __messages_flag=$2
    local __msg=$3
    
    local __debug_info="lev:${__loglevel} b_flag:${__breakpointflag} x_flag:${__xlogdebugflag}"
    
    local __datetime=`date +'%F %H:%M:%S'`
    local __new_func=(${FUNCNAME[@]})
    unset __new_func[${#__new_func[@]}-1]
    unset __new_func[0]
    
    #为了节约时间,函数调用栈就不反序输出了
    #local anti_new_func=(`awk '{for(i=NF;i>0;i--)printf $i" "}' <<<"${__new_func[@]}"`)
    
    local __log_mark=""
    local __i=0
    local __func_num=${#__new_func[@]}
    
    local __tmp_file="${__logdir}/log_debug_temp_${__logfile}"
    local __color_debug_print_info=""
    local __nocolor_debug_print_info=""
    
    local __color_file_list=""
    local __nocolor_file_list=""
    
    
    #让日志显示函数层级,要求模块都只打印单行信息(就像缩进一样,进一步可以扩展到多文件的场景,如果有锁机制,那么可以同时写一个大日志文件)
    #确定日志树的层级
    #判断下日志文件的后缀格式,如果是py结尾的,那么直接使用空格作为缩进(可以使用文本编辑器折叠日志文件)
    if [ ".py" = "${__logfile:0-3:3}" ] ; then
        local __c_mark=" "
        local __block_num=$[__func_num]
    else
        local __block_num=$[__func_num*2-1]
    fi

    ##根据层级打标签
    __log_mark=`awk -v __i=${__func_num} -v n="${__c_mark}" '
        {
            all_mark="";
            for(a=0;a<__i;a++)
            {
                if(n==" ")
                {
                    # 这里的缩进要和下面相同
                    all_mark=(all_mark"""    ");
                    continue;
                }
                if(a==__i-1)
                     all_mark=(all_mark"""o");                       
                else
                     all_mark=(all_mark"""|-");
            }
            printf("%s",all_mark);
        }
        ' <<<" "`
        
    local __actul_num=(${BASH_LINENO[@]})
    unset __actul_num[${#__actul_num[@]}-1]
    
    #__msg中的换行数据需要处理
    local __new_msg=`awk -v __i=${__block_num} -v n="${__c_mark}" '
        {
            m="";
            for(a=0;a<__i+1;a++)
            {
                if(a!=__i)
                {
                    if(n==" ")
                    {
                        #这里的缩进要和上面相同
                        m=(m"""    ");
                    }
                    else
                    {
                        m=(m""" ");
                    }
                }
            }
            all_line[NR] = $0;
        }
        END{
            for(__i=1;__i<=NR;__i++)
                printf("%s%s\n",m,all_line[__i]);
        }
        ' <<<"$__msg"`
    
    local __now_dir=$(pwd)    
    local __logformat="%-7s ${__datetime} dir:${__now_dir//[^\_\-0-9a-zA-Z\/\.]/@} file:${BASH_SOURCE[1]//[^\_\-0-9a-zA-Z\/\.]/@} func:${__new_func[@]} [line:${__actul_num[@]}]\n${__new_msg}"
    {   
        case ${__logtype} in  
                debug)
                    [[ $__loglevel -le 0 ]] && printf "%s\033[35m${__logformat}\033[0m\n" "$__log_mark" "[D][${__logtype}]";;
                info)
                    [[ $__loglevel -le 1 ]] && printf "%s\033[32m${__logformat}\033[0m\n" "$__log_mark" "[D][${__logtype}]";;
                warn)
                    [[ $__loglevel -le 2 ]] && printf "%s\033[33m${__logformat}\033[0m\n" "$__log_mark" "[D][${__logtype}]";;
                error)
                    [[ $__loglevel -le 3 ]] && printf "%s\033[31m${__logformat}\033[0m\n" "$__log_mark" "[D][${__logtype}]";;
        esac
    } | tee ${__tmp_file}
    
    local __log_str_with_color=$(<${__tmp_file})
    local __log_str=`sed 's/\x1b\[[0-9;]*m//g' ${__tmp_file}`
    
    echo "$__log_str" >>${__logdir}/${__logfile}
    
    case "$__messages_flag" in
        sc*)
            echo "$__log_str_with_color" >/dev/ttyS0 2>/dev/null
            echo "$__log_str_with_color" >/dev/ttyAMA0 2>/dev/null
            ;;
        sb*)
            echo "$__log_str" >/dev/ttyS0 2>/dev/null
            echo "$__log_str" >/dev/ttyAMA0 2>/dev/null
            ;;
    esac
    
    case "$__messages_flag" in
        *m)
            logger "$__log_str"
            ;;
    esac
    
    #断点
    if [ "1" = "$__breakpointflag" -a "b" = "$__break_flag" ] \
        || [ "1" = "$__breakpointflag" -a "b-x" = "$__break_flag" ] \
        || [ 'v' = "$__messages_flag" ] \
        || [ 'f' = "$__messages_flag" ] \
        || [ 'vf' = "$__messages_flag" ] ; then
        #在进入断点前会打印当前环境所有的变量信息
        declare -p >${__var_cur_file_tmp}
        # 剔除日志变量
        #初始化中需要删除的行
        sed -i '/declare -a BASH_LINENO=/d' ${__var_cur_file_tmp}
        sed -i '/declare -a BASH_SOURCE=/d' ${__var_cur_file_tmp}
        sed -i '/declare -a FUNCNAME=/d' ${__var_cur_file_tmp}
        sed -i '/declare -i LINENO=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __loglevel=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __logfile=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __logdir=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __breakpointflag=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __xlogdebugflag=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __var_init_file=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __var_cur_file=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __var_cur_file_tmp=/d' ${__var_cur_file_tmp}
        
        sed -i '/declare -- __logtype=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __break_flag=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __messages_flag=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __msg=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __datetime=/d' ${__var_cur_file_tmp}
        sed -i '/declare -a __new_func=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __log_mark=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __i=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __func_num=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __tmp_file=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __var_cur_file_tmp=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __c_mark=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __block_num=/d' ${__var_cur_file_tmp}
        sed -i '/declare -a __actul_num=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __new_msg=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __now_dir=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __logformat=/d' ${__var_cur_file_tmp}
        
        sed -i '/declare -a BASH_ARGC=/d' ${__var_cur_file_tmp}
        sed -i '/declare -a BASH_ARGV=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- _=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __var_cur_file_deal_again=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __var_cur_file_deal_out_put_temp=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __color_debug_print_info=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __nocolor_debug_print_info=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __color_file_list=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __nocolor_file_list=/d' ${__var_cur_file_tmp}
        
        sed -i '/declare -- __all_file_list_init=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __all_file_list_now=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __all_file_list_change=/d' ${__var_cur_file_tmp}
        
        # 单独处理两个可能换行的变量
        # 先删除两个模式中间的行
        sed -i '/declare -- __log_str_with_color=/,/declare -/{/declare -- __log_str_with_color=/!{/declare -/!d}}' ${__var_cur_file_tmp}
        sed -i '/declare -- __log_str=/,/declare -/{/declare -- __log_str=/!{/declare -/!d}}' ${__var_cur_file_tmp}
        sed -i '/declare -- __log_str_with_color=/d' ${__var_cur_file_tmp}
        sed -i '/declare -- __log_str=/d' ${__var_cur_file_tmp}
        
        diff --unified=10000 ${__var_init_file} ${__var_cur_file_tmp} | sed '1,3d' | grep "^+"  >${__var_cur_file_tmp2}
        awk '
            {
                #读入文件中所有的行
                all_line[NR] = $0;
            }
            END{
                for(i=1;i<=NR;i++)
                {
                    print_info=substr(all_line[i], 2, length(all_line[i]))
                    if(0!=match(all_line[i], /^-/))
                    {
                        continue;
                    }
                    else
                    {
                        printf("%s\n", print_info)
                    }
                }
            }
        ' ${__var_cur_file_tmp2} >${__var_cur_file}
        
        
        echo "[40;32m---now variable info---[0m"
        sed -r 's/^declare -([a-zA-Z-]+) ([_a-zA-Z][_0-9a-zA-Z]{0,})/[\1] \2/g' ${__var_cur_file} > ${__var_cur_file_deal_again}
        if [ ! -s ${__var_cur_file_deal} ] ; then
            mv ${__var_cur_file_deal_again} ${__var_cur_file_deal}
            cat ${__var_cur_file_deal} 
            __nocolor_debug_print_info=`cat ${__var_cur_file_deal}`
        else
            if diff --unified=10000  ${__var_cur_file_deal} ${__var_cur_file_deal_again} >${__var_cur_file_deal_out_put_temp} ; then
                mv ${__var_cur_file_deal_again} ${__var_cur_file_deal}
                cat ${__var_cur_file_deal}
                __nocolor_debug_print_info=`cat ${__var_cur_file_deal}`
            else
                mv ${__var_cur_file_deal_again} ${__var_cur_file_deal}
                sed -i '1,3d' ${__var_cur_file_deal_out_put_temp}
                __color_debug_print_info=$(awk '
                    {
                        #读入文件中所有的行
                        all_line[NR] = $0;
                    }
                    END{
                        for(i=1;i<=NR;i++)
                        {
                            if(0!=match(all_line[i], /^-\[.+\] ([a-zA-Z_0-9]+)=/, a))
                            {
                                all_sub_var[a[1]]=1;
                            }
                        }
                        
                        for(i=1;i<=NR;i++)
                        {
                            print_info=substr(all_line[i], 2, length(all_line[i]))
                            if(0!=match(all_line[i], /^-/))
                            {
                                continue;
                            }
                            else if(0!=match(all_line[i], /^\+\[.+\] ([a-zA-Z_0-9]+)=/, a))
                            {
                                if(all_sub_var[a[1]]==1)
                                {
                                    #显示改变的颜色
                                    new_line=("\033[31m"print_info"\033[0m")
                                    printf("%s\n", new_line)
                                }
                                else
                                {
                                    #显示新增的颜色
                                    new_line=("\033[34m"print_info"\033[0m")
                                    printf("%s\n", new_line)
                                }
                            
                            }
                            else if(0!=match(all_line[i], /^\+/, a))
                            {
                                #显示新增的颜色
                                new_line=("\033[34m"print_info"\033[0m")
                                printf("%s\n", new_line)
                            }
                            else
                            {
                                #显示本色
                                printf("%s\n", print_info)
                            }
                        }
                    }
                ' ${__var_cur_file_deal_out_put_temp})
                
                __nocolor_debug_print_info=$(awk '
                    {
                        #读入文件中所有的行
                        all_line[NR] = $0;
                    }
                    END{                        
                        for(i=1;i<=NR;i++)
                        {
                            print_info=substr(all_line[i], 2, length(all_line[i]))
                            if(0!=match(all_line[i], /^-/))
                            {
                                continue;
                            }
                            else
                            {
                                #显示本色
                                printf("%s\n", print_info)
                            }
                        }
                    }
                ' ${__var_cur_file_deal_out_put_temp})
                
                # 这里要注意下,如果是简单变量客户端显示模式,那么这里只显示指定变量
                if [ "no-var" != "$__messages_flag" ] ; then
                    echo "$__color_debug_print_info"
                else
                    local __var_show sub_var
                    rm -f "${__logdir}/__simple_var_${__logfile}"
                    rm -f "${__logdir}/__simple_var_deal_${__logfile}"
                    # 读取终端指令variables
                    read -p "[40;32mvariables to show:[0m" __var_show
                    if [ -n "$__var_show" ] ; then
                        for sub_var in $__var_show
                        do
                            declare -p ${sub_var}  >>"${__logdir}/__simple_var_${__logfile}"
                        done
                        sed -r 's/^declare -([a-zA-Z-]+) ([_a-zA-Z][_0-9a-zA-Z]{0,})/[\1] \2/g' "${__logdir}/__simple_var_${__logfile}" > "${__logdir}/__simple_var_deal_${__logfile}"
                        cat "${__logdir}/__simple_var_deal_${__logfile}"
                    fi
                fi
            fi
        fi
        echo "[40;32m-----------------------[0m"
        
        if [ "v" = "$__messages_flag" -o "vf" = "$__messages_flag" ] ; then
            # 不使用断点功能
            echo "$__nocolor_debug_print_info" >>${__logdir}/${__logfile} 
        fi
        
        if [ 'f' = "$__messages_flag" -o "vf" = "$__messages_flag" ] ; then
            # 处理文件变更情况
            if [ ! -s ${__all_file_list_init} ] ; then
                ls ${__logdir} --full-time | sed '1d' | grep -v "_${__logfile}$" | grep -vw "${__logfile}" | sort -u | awk '{print $(NF)" "$(NF-1)" "$(NF-2)}' >${__all_file_list_init}
                __nocolor_file_list=`cat ${__all_file_list_init}`
                __color_file_list=${__nocolor_file_list}
            else
                ls ${__logdir} --full-time | sed '1d' | grep -v "_${__logfile}$" | grep -vw "${__logfile}" | sort -u |awk '{print $(NF)" "$(NF-1)" "$(NF-2)}' >${__all_file_list_now}
                if diff --unified=10000 ${__all_file_list_init} ${__all_file_list_now} >${__all_file_list_change} ; then
                    mv ${__all_file_list_now} ${__all_file_list_init}
                    __nocolor_file_list=`cat ${__all_file_list_init}`
                    __color_file_list=${__nocolor_file_list}
                else
                    sed -i '1,3d' ${__all_file_list_change}
                    mv ${__all_file_list_now} ${__all_file_list_init}
                    #文件发生改变
                    __color_file_list=$(awk '
                        {
                            #读入文件中所有的行
                            all_line[NR] = $0;
                        }
                        END{
                            for(i=1;i<=NR;i++)
                            {
                                if(0!=match(all_line[i], /^-(.+) .+ /, a))
                                {
                                    all_sub_var[a[1]]=1;
                                }
                            }
                            
                            for(i=1;i<=NR;i++)
                            {
                                print_info=substr(all_line[i], 2, length(all_line[i]))
                                if(0!=match(all_line[i], /^-/))
                                {
                                    continue;
                                }
                                else if(0!=match(all_line[i], /^+(.+) .+ /, a))
                                {
                                    if(all_sub_var[a[1]]==1)
                                    {
                                        #显示改变的颜色
                                        new_line=("\033[31m"print_info"\033[0m")
                                        printf("%s\n", new_line)
                                    }
                                    else
                                    {
                                        #显示新增的颜色
                                        new_line=("\033[34m"print_info"\033[0m")
                                        printf("%s\n", new_line)
                                    }
                                
                                }
                                else
                                {
                                    #显示本色
                                    printf("%s\n", print_info)
                                }
                            }
                        }
                    ' ${__all_file_list_change})
                    
                    __nocolor_file_list=$(awk '
                        {
                            #读入文件中所有的行
                            all_line[NR] = $0;
                        }
                        END{
                            for(i=1;i<=NR;i++)
                            {
                                print_info=substr(all_line[i], 2, length(all_line[i]))
                                if(0!=match(all_line[i], /^-/))
                                {
                                    continue;
                                }
                                else
                                {
                                    #显示本色
                                    printf("%s\n", print_info)
                                }
                            }
                        }
                    ' ${__all_file_list_change})
                fi
            fi
            # 不使用断点功能
            echo "$__nocolor_file_list" >>${__logdir}/${__logfile} 
            echo "[40;32m---file change list----[0m"
            echo "$__color_file_list"
            echo "[40;32m-----------------------[0m"
        fi
        
        if [ 'v' = "$__messages_flag" -o 'f' = "$__messages_flag" -o "vf" = "$__messages_flag" ] \
            && ! [ "1" = "$__breakpointflag" -a "b" = "$__break_flag" ] \
            && ! [ "1" = "$__breakpointflag" -a "b-x" = "$__break_flag" ] ; then
            return
        fi
        
        #保存全部终端设置
        local savedstty=`stty -g 2>/dev/null`
        #禁止回显
        stty -echo 2>/dev/null
        dd if=/dev/tty bs=1 count=1 2>/dev/null
        #打开回显
        stty echo 2>/dev/null
        stty $savedstty 2>/dev/null
    fi
    
    #调试
    if [ "1" = "$__xlogdebugflag" -a "x" = "$__break_flag" ] \
        || [ "1" = "$__xlogdebugflag" -a "b-x" = "$__break_flag" ] ; then
        shift 3
        # :TODO: eval -- $@ 更安全?
        eval $@
    fi
}

#---------------------------------------------------------------------------------------------------
# FUNCTION NAME: lg_dbug
#   DESCRIPTION: 日志打印函数简化版本,执行一次打印大概0.018s,对效率要求很高的脚本不用使用调试函数
#                或者是把日志级别设置为大于3的数
#     PARAMETER: out:
#                in:
#                   __loglevel:全局变量,打印机别0 1 2 3,数字越小打印机别越高,超过3将屏蔽所有日志打印和所有断点
#                   __logfile:全局变量,需要保存的日志文件名
#                   1=>日志类别
#                      d i w e 正常的打印信息
#                   2=>当前日志是否需要追加系统日志文件是否需要打印到串口
#                      n: 不需要处理
#                      sc: 需要打印到串口(带颜色字符)
#                      sb: 需要打印到串口(不带颜色字符)
#                      m: 需要输出到系统messages
#                      sc-m:打印到串口(带颜色字符),同时输出到messages
#                      sb-m:打印到串口(不带颜色字符),同时输出到messages
#                   3=>当前是否是纯变量打印
#                      y:纯变量打印
#                      n:不是纯变量打印
#                      传y时候的传参格式为:
#                          lg_dbug "d" "n" "n" "xxx:{xx};zz:{mm};kk:{jj};:{zz};"
#                          每一个变量都是以冒号开始分号结束,冒号前面可以加描述性语句
#                   4=>需要打印的详细信息
#        RETRUN: 成功=>0
#                失败=>1
#UPDATE HISTORY: xx 2022-07-07
#                   新建
#---------------------------------------------------------------------------------------------------
lg_dbug ()
{
    local - ; set +xv
    local __logtype=${1##*-}
    local __log_type_print=""
    case "$__loglevel" in
        0)
            :
            ;;
        1)
            if [ "${__logtype}" = "d" ] ; then
                return 0
            fi
            ;;
        2)
            if [ "${__logtype}" = "d" -o "${__logtype}" = "i" ] ; then
                return 0
            fi
            ;;
        3)
            if [ "${__logtype}" != "e" ] ; then
                return 0
            fi
            ;;
        *)
            return 1
            ;;
    esac
    
    local __messages_flag=$2
    local __var_flag=$3
    local __msg_ori=$4
    local __msg=""
    
    # __msg_ori如果是变量(格式 xxx:{xx};zz:{mm};kk:{jj};:{zz};),那么直接用declare -p替换
    if [ "y" = "$__var_flag" ] ; then
        local __cnt_num=`awk -F ";" '{print NF}' <<<"$__msg_ori"`
        local __tmp_str1 __tmp_str2 __tmp_cnt __tmp_str __tmp_str2_tmp
        for((__tmp_cnt=1;__tmp_cnt<__cnt_num;__tmp_cnt++))
        do
            __tmp_str=`awk -F ";" '{print $'$__tmp_cnt'}' <<<"$__msg_ori"`
            __tmp_str1=`awk -F ":" '{print $1}' <<<"$__tmp_str"`
            __tmp_str2=`awk -F ":{" '{print $2}' <<<"$__tmp_str" | awk -F "}" '{print $1}'`
            if [ -n "$__tmp_str2" ] ; then
                __tmp_str2_tmp=`declare -p ${__tmp_str2} 2>/dev/null`
            else
                __tmp_str2_tmp=""
            fi
            
            if [ -n "$__tmp_str2_tmp" ] ; then
                __tmp_str2=${__tmp_str2_tmp:8}
            else
                __tmp_str2="${__tmp_str2} not set"
            fi
            __msg+="${__tmp_str1}{${__tmp_str2}} "
        done
    else
        __msg="$__msg_ori"
    fi
    
    local __datetime=`date +'%FT%H:%M:%S'`
    local __new_func=(${FUNCNAME[@]})
    unset __new_func[${#__new_func[@]}-1]
    unset __new_func[0]
    
    #为了节约时间,函数调用栈就不反序输出了
    #local anti_new_func=(`awk '{for(i=NF;i>0;i--)printf $i" "}' <<<"${__new_func[@]}"`)
    
    local __log_mark=""
    local __i=0
    local __func_num=${#__new_func[@]}
    
    local __tmp_file="${__logdir}/log_debug_temp_${__logfile}"
    
    
    #让日志显示函数层级,要求模块都只打印单行信息(就像缩进一样,进一步可以扩展到多文件的场景,如果有锁机制,那么可以同时写一个大日志文件)
    #确定日志树的层级
    #判断下日志文件的后缀格式,如果是py结尾的,那么直接使用空格作为缩进(可以使用文本编辑器折叠日志文件)
    if [ ".py" = "${__logfile:0-3:3}" ] ; then
        local __c_mark=" "
        local __block_num=$[__func_num]
    else
        local __block_num=$[__func_num*2-1]
    fi

    ##根据层级打标签
    __log_mark=`awk -v __i=${__func_num} -v n="${__c_mark}" '
        {
            all_mark="";
            for(a=0;a<__i;a++)
            {
                if(n==" ")
                {
                    # 这里的缩进要和下面相同
                    all_mark=(all_mark"""    ");
                    continue;
                }
                if(a==__i-1)
                     all_mark=(all_mark"""o");                       
                else
                     all_mark=(all_mark"""|-");
            }
            printf("%s",all_mark);
        }
        ' <<<" "`
        
    local __actul_num=(${BASH_LINENO[@]})
    unset __actul_num[${#__actul_num[@]}-1]
    local __now_dir=$(pwd)    
    local __logformat="[${__actul_num[0]}:${__new_func[1]} ${__datetime} %-1s]${__msg}"
    {   
        case ${__logtype} in  
                d)
                    [[ $__loglevel -le 0 ]] && printf "%s\033[35m${__logformat}\033[0m\n" "$__log_mark" "D";;
                i)
                    [[ $__loglevel -le 1 ]] && printf "%s\033[32m${__logformat}\033[0m\n" "$__log_mark" "I";;
                w)
                    [[ $__loglevel -le 2 ]] && printf "%s\033[33m${__logformat}\033[0m\n" "$__log_mark" "W";;
                e)
                    [[ $__loglevel -le 3 ]] && printf "%s\033[31m${__logformat}\033[0m\n" "$__log_mark" "E";;
        esac
    } | tee ${__tmp_file}
    
    local __log_str_with_color=$(<${__tmp_file})
    local __log_str=`sed 's/\x1b\[[0-9;]*m//g' ${__tmp_file}`
    
    echo "$__log_str" >>${__logdir}/${__logfile}
    
    case "$__messages_flag" in
        sc*)
            echo "$__log_str_with_color" >/dev/ttyS0 2>/dev/null
            echo "$__log_str_with_color" >/dev/ttyAMA0 2>/dev/null
            ;;
        sb*)
            echo "$__log_str" >/dev/ttyS0 2>/dev/null
            echo "$__log_str" >/dev/ttyAMA0 2>/dev/null
            ;;
    esac
    
    case "$__messages_flag" in
        *m)
            logger "$__log_str"
            ;;
    esac
    
}

#---------------------------------------------------------------------------------------------------
# FUNCTION NAME: dbg_no_var
#   DESCRIPTION: 日志打印函数最简化版本,不自动打印变量,执行一次打印大概0.018s,对效率要求很高的脚本不用使用调试函数
#                或者是把日志级别设置为大于3的数
#     PARAMETER: out:
#                in:
#                   __loglevel:全局变量,打印机别0 1 2 3,数字越小打印机别越高,超过3将屏蔽所有日志打印和所有断点
#                   __logfile:全局变量,需要保存的日志文件名
#                   1=>日志类别
#                      d i w e 正常的打印信息
#                   2=>需要打印的详细信息,变量需要传入$
#        RETRUN: 成功=>0
#                失败=>1
#UPDATE HISTORY: xx 2022-07-07
#                   新建
#---------------------------------------------------------------------------------------------------
dbg_no_var ()
{
    local - ; set +xv
    local __logtype=${1##*-}
    local __log_type_print=""
    case "$__loglevel" in
        0)
            :
            ;;
        1)
            if [ "${__logtype}" = "d" ] ; then
                return 0
            fi
            ;;
        2)
            if [ "${__logtype}" = "d" -o "${__logtype}" = "i" ] ; then
                return 0
            fi
            ;;
        3)
            if [ "${__logtype}" != "e" ] ; then
                return 0
            fi
            ;;
        *)
            return 1
            ;;
    esac
    
    local __msg=$2
    
    local __datetime=`date +'%FT%H:%M:%S'`
    local __new_func=(${FUNCNAME[@]})
    unset __new_func[${#__new_func[@]}-1]
    unset __new_func[0]
    
    #为了节约时间,函数调用栈就不反序输出了
    #local anti_new_func=(`awk '{for(i=NF;i>0;i--)printf $i" "}' <<<"${__new_func[@]}"`)
    
    local __log_mark=""
    local __i=0
    local __func_num=${#__new_func[@]}
    
    local __tmp_file="${__logdir}/log_debug_temp_${__logfile}"
    
    
    #让日志显示函数层级,要求模块都只打印单行信息(就像缩进一样,进一步可以扩展到多文件的场景,如果有锁机制,那么可以同时写一个大日志文件)
    #确定日志树的层级
    #判断下日志文件的后缀格式,如果是py结尾的,那么直接使用空格作为缩进(可以使用文本编辑器折叠日志文件)
    if [ ".py" = "${__logfile:0-3:3}" ] ; then
        local __c_mark=" "
        local __block_num=$[__func_num]
    else
        local __block_num=$[__func_num*2-1]
    fi

    ##根据层级打标签
    __log_mark=`awk -v __i=${__func_num} -v n="${__c_mark}" '
        {
            all_mark="";
            for(a=0;a<__i;a++)
            {
                if(n==" ")
                {
                    # 这里的缩进要和下面相同
                    all_mark=(all_mark"""    ");
                    continue;
                }
                if(a==__i-1)
                     all_mark=(all_mark"""o");                       
                else
                     all_mark=(all_mark"""|-");
            }
            printf("%s",all_mark);
        }
        ' <<<" "`
        
    local __actul_num=(${BASH_LINENO[@]})
    unset __actul_num[${#__actul_num[@]}-1]
    local __now_dir=$(pwd)    
    local __logformat="[${__actul_num[0]}:${__new_func[1]} ${__datetime} %-1s]${__msg}"
    {   
        case ${__logtype} in  
                d)
                    [[ $__loglevel -le 0 ]] && printf "%s\033[35m${__logformat}\033[0m\n" "$__log_mark" "D";;
                i)
                    [[ $__loglevel -le 1 ]] && printf "%s\033[32m${__logformat}\033[0m\n" "$__log_mark" "I";;
                w)
                    [[ $__loglevel -le 2 ]] && printf "%s\033[33m${__logformat}\033[0m\n" "$__log_mark" "W";;
                e)
                    [[ $__loglevel -le 3 ]] && printf "%s\033[31m${__logformat}\033[0m\n" "$__log_mark" "E";;
        esac
    } | tee ${__tmp_file}
    
    local __log_str_with_color=$(<${__tmp_file})
    local __log_str=`sed 's/\x1b\[[0-9;]*m//g' ${__tmp_file}`
    
    echo "$__log_str" >>${__logdir}/${__logfile}
}

#---------------------------------------------------------------------------------------------------
# FUNCTION NAME: dbg
#   DESCRIPTION: 日志打印函数最简化版本,自动打印变量,执行一次打印大概0.018s,对效率要求很高的脚本不用使用调试函数
#                或者是把日志级别设置为大于3的数
#                lg_dbug "d" "xxx:{xx};zz:{mm};kk:{jj};:{zz};"
#                每一个变量都是以冒号开始分号结束,冒号前面可以加描述性语句
#     PARAMETER: out:
#                in:
#                   __loglevel:全局变量,打印机别0 1 2 3,数字越小打印机别越高,超过3将屏蔽所有日志打印和所有断点
#                   __logfile:全局变量,需要保存的日志文件名
#                   1=>日志类别
#                      d i w e 正常的打印信息
#                   2=>需要打印的详细信息,带变量打印,变量按照指定格式传入
#        RETRUN: 成功=>0
#                失败=>1
#UPDATE HISTORY: xx 2022-07-07
#                   新建
#---------------------------------------------------------------------------------------------------
dbg ()
{
    local - ; set +xv
    local __logtype=${1##*-}
    local __log_type_print=""
    case "$__loglevel" in
        0)
            :
            ;;
        1)
            if [ "${__logtype}" = "d" ] ; then
                return 0
            fi
            ;;
        2)
            if [ "${__logtype}" = "d" -o "${__logtype}" = "i" ] ; then
                return 0
            fi
            ;;
        3)
            if [ "${__logtype}" != "e" ] ; then
                return 0
            fi
            ;;
        *)
            return 1
            ;;
    esac
    
    local __msg_ori=$2
    local __msg=""
    
    # __msg_ori如果是变量(格式 xxx:{xx};zz:{mm};kk:{jj};:{zz};),那么直接用declare -p替换
    local __cnt_num=`awk -F ";" '{print NF}' <<<"$__msg_ori"`
    local __tmp_str1 __tmp_str2 __tmp_cnt __tmp_str __tmp_str2_tmp
    for((__tmp_cnt=1;__tmp_cnt<__cnt_num;__tmp_cnt++))
    do
        __tmp_str=`awk -F ";" '{print $'$__tmp_cnt'}' <<<"$__msg_ori"`
        __tmp_str1=`awk -F ":" '{print $1}' <<<"$__tmp_str"`
        __tmp_str2=`awk -F ":{" '{print $2}' <<<"$__tmp_str" | awk -F "}" '{print $1}'`
        if [ -n "$__tmp_str2" ] ; then
            __tmp_str2_tmp=`declare -p ${__tmp_str2} 2>/dev/null`
        else
            __tmp_str2_tmp=""
        fi
        
        if [ -n "$__tmp_str2_tmp" ] ; then
            __tmp_str2=${__tmp_str2_tmp:8}
        else
            __tmp_str2="${__tmp_str2} not set"
        fi
        __msg+="${__tmp_str1}{${__tmp_str2}} "
    done
    
    local __datetime=`date +'%FT%H:%M:%S'`
    local __new_func=(${FUNCNAME[@]})
    unset __new_func[${#__new_func[@]}-1]
    unset __new_func[0]
    
    #为了节约时间,函数调用栈就不反序输出了
    #local anti_new_func=(`awk '{for(i=NF;i>0;i--)printf $i" "}' <<<"${__new_func[@]}"`)
    
    local __log_mark=""
    local __i=0
    local __func_num=${#__new_func[@]}
    
    local __tmp_file="${__logdir}/log_debug_temp_${__logfile}"
    
    
    #让日志显示函数层级,要求模块都只打印单行信息(就像缩进一样,进一步可以扩展到多文件的场景,如果有锁机制,那么可以同时写一个大日志文件)
    #确定日志树的层级
    #判断下日志文件的后缀格式,如果是py结尾的,那么直接使用空格作为缩进(可以使用文本编辑器折叠日志文件)
    if [ ".py" = "${__logfile:0-3:3}" ] ; then
        local __c_mark=" "
        local __block_num=$[__func_num]
    else
        local __block_num=$[__func_num*2-1]
    fi

    ##根据层级打标签
    __log_mark=`awk -v __i=${__func_num} -v n="${__c_mark}" '
        {
            all_mark="";
            for(a=0;a<__i;a++)
            {
                if(n==" ")
                {
                    # 这里的缩进要和下面相同
                    all_mark=(all_mark"""    ");
                    continue;
                }
                if(a==__i-1)
                     all_mark=(all_mark"""o");                       
                else
                     all_mark=(all_mark"""|-");
            }
            printf("%s",all_mark);
        }
        ' <<<" "`
        
    local __actul_num=(${BASH_LINENO[@]})
    unset __actul_num[${#__actul_num[@]}-1]
    local __now_dir=$(pwd)    
    local __logformat="[${__actul_num[0]}:${__new_func[1]} ${__datetime} %-1s]${__msg}"
    {   
        case ${__logtype} in  
                d)
                    [[ $__loglevel -le 0 ]] && printf "%s\033[35m${__logformat}\033[0m\n" "$__log_mark" "D";;
                i)
                    [[ $__loglevel -le 1 ]] && printf "%s\033[32m${__logformat}\033[0m\n" "$__log_mark" "I";;
                w)
                    [[ $__loglevel -le 2 ]] && printf "%s\033[33m${__logformat}\033[0m\n" "$__log_mark" "W";;
                e)
                    [[ $__loglevel -le 3 ]] && printf "%s\033[31m${__logformat}\033[0m\n" "$__log_mark" "E";;
        esac
    } | tee ${__tmp_file}
    
    local __log_str_with_color=$(<${__tmp_file})
    local __log_str=`sed 's/\x1b\[[0-9;]*m//g' ${__tmp_file}`
    
    echo "$__log_str" >>${__logdir}/${__logfile}
    
}

