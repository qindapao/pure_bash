. ./meta/meta.sh
((DEFENSE_VARIABLES[trap_return]++)) && return 0

# 陷阱函数中千万不能打印东西到标准输出或者错误输出,不然可能会被正常脚本代码捕捉
# 子shell中继承陷阱
# set -T 子shell 中 继承RETURN 和 DEBUG 陷阱
# 因为听说DEBUG陷阱往子shell中传播会造成混乱
# set -T

. ./date/date_log.sh || return 1
. ./trap/trap_local_vars.sh || return 1


# :TODO: set -xv 这两个选项结合起来调试威力更大
# # 第一次进来的时候记录当前环境中的所有变量名
# :TODO: 嵌入式环境中< <()语法可能失效,提示没有相关的文件描述符
# mapfile -t _LOG_INIT_VARIABLES_NAME < <(compgen -A variable)

TRAP_RETURN_FILE="trap_return_$(date_log).log"

# 捕捉脚本中的函数return信号,并设置return处理函数
trap_return ()
{
    disable_xv
    local _trap_return_last_command_ext_code=$?
    local _trap_return_pipestatus=$1

    # :TODO: 删除局部变量? 可能并不好,这样会把所有局部作用域变量全部清零,暂时还是手动清理
    # 返回函数的值?(会被错误函数捕捉,所以这里也不用处理)
    # 如果使能了trap_return 那么删除局部变量的跟踪
    # 如果要关闭,手动执行
    #   trap - RETURN
    # 如果要重新打开
    #   trap 'trap_return' RETURN
    
    # 这里要判断下当前的名字,如果是 trap_local_vars 和 trap_global_vars 不处理
    # :TODO: 这里还有一个问题就是:只要trap_local_vars trap_global_vars后面调用了任何一个函数都
    # 会导致局部变量被清除
    # 所以如果想手动控制变量的打印和关闭,禁用这里的RETURN陷阱
    case "${FUNCNAME[1]}" in
        trap_local_vars|trap_global_vars)
            :
            ;;
        *)
            local _trap_return_var
            for _trap_return_var in "${!TRAP_LOCAL_VARS[@]}" ; do
                [[ "${TRAP_LOCAL_VARS["$_trap_return_var"]+set}" ]] && {
                    # 如果发现hash表中有对应键取消掉
                    unset -v 'TRAP_LOCAL_VARS[$_trap_return_var]'
                }
            done
            ;;
    esac
    
    return 0
}

return 0

