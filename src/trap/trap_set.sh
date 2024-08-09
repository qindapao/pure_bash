. ./meta/meta.sh
((DEFENSE_VARIABLES[trap_set]++)) && return 0

. ./trap/trap_err.sh || return 1
. ./trap/trap_exit.sh || return 1
. ./trap/trap_return.sh || return 1

IS_ALLOW_TRAP_SET=1

# 生成一段可以执行的代码,在函数的外部执行
# 不用直接调用函数执行,比如在顶层主shell执行,这样所有的子shell才能继承陷阱
# 外部脚本使用方法(注意:这个函数只是生成代码并不能直接调用)
# IS_ALLOW_TRAP_SET=1
# eval $(trap_set 1 ERR)
# eval $(trap_set 1 RETURN)
# eval $(trap_set 1 EXIT)
# eval $(trap_set 1 DEBUG)
# 临时取消陷阱的方法
# eval $(trap_set 0 ERR)
# eval $(trap_set 0 RETURN)
# eval $(trap_set 0 EXIT)
# eval $(trap_set 0 DEBUG)
# 如果要在脚本的最上面取消陷阱，这样所有的陷阱设置将失效。
# IS_ALLOW_TRAP_SET=0

# :TODO: 更好更高效的方式是把所有的槽位都放到一个全局的关联数组中,然后外面eval来执行
trap_set ()
{
    # 是否不允许设置陷阱
    ((IS_ALLOW_TRAP_SET)) || {
        return
    }

    # 1: enable 0: disable
    local _trap_set_is_enable=$1 _trap_set_type=$2
    local -A _trap_set_funcs=([ERR]=trap_err [RETURN]=trap_return [EXIT]=trap_exit)

    case "$_trap_set_is_enable" in
    1)
        case "$_trap_set_type" in
        # :TODO: 这里需要还原$_的值,但是不清楚是否会有副作用(可能有副作用,暂时屏蔽)
        # :TODO: 去除脚本中引用$_变量的地方
        # DEBUG)  printf "%s\n" "set -T;trap 'OLD_=\"\$_\";DEBUG_LINE_OLD=\$DEBUG_LINE;DEBUG_LINE=\${LINENO};: \"\$OLD_\"' DEBUG" ;;
        DEBUG)  printf "%s\n" "set -T;trap 'DEBUG_LINE_OLD=\$DEBUG_LINE;DEBUG_LINE=\${LINENO}' DEBUG" ;;
        EXIT)   printf "%s\n" "trap '${_trap_set_funcs[$_trap_set_type]} \"\${PIPESTATUS[*]}\" \"\$DEBUG_LINE_OLD\" \"\$BASH_COMMAND\"' EXIT" ;;
        # set +E(关闭错误传播)和set -E(打开错误传播)不在这里处理,在业务脚本中自己打开和关闭
        ERR)    printf "%s\n" "trap '${_trap_set_funcs[$_trap_set_type]} \"\${PIPESTATUS[*]}\" \"\$BASH_COMMAND\"' ERR" ;;
        # 如果业务代码中不需要捕捉子陷阱的错误,那么手动在try块第一行设置 set +E
        # ERR)    printf "%s\n" "trap '${_trap_set_funcs[$_trap_set_type]} \"\${PIPESTATUS[*]}\" \"\$BASH_COMMAND\"' ERR" ;;
        RETURN) printf "%s\n" "set -T;trap '${_trap_set_funcs[$_trap_set_type]} \"\${PIPESTATUS[*]}\"' ${_trap_set_type}" ;;
        esac
        ;;
    0)
        case "$_trap_set_type" in
        DEBUG)  printf "%s\n" "set +T;trap - ${_trap_set_type}" ;;
        EXIT)   printf "%s\n" "trap - ${_trap_set_type}" ;;
        ERR)    printf "%s\n" "trap - ${_trap_set_type}" ;;
        RETURN) printf "%s\n" "set +T;trap - ${_trap_set_type}" ;;
        esac
        ;;
    esac
}

return 0

