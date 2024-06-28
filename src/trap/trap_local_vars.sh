. ./meta/meta.sh
((DEFENSE_VARIABLES[trap_local_vars]++)) && return 0


# 用一个全局的HASH表的键保存所有的需要陷阱函数打印的局部变量的值(值可以动态更新,方便调试)
# 陷阱函数无法打印函数的局部变量的值
# 基本用法是这样的
# other_func2 ()
# {
#     local d=1 e=2 f=3
#     trap_local_vars 1 d e f
#     
#     other_func3
#   
#     trap_local_vars 0 d e f
# }

declare -gA TRAP_LOCAL_VARS=()

trap_local_vars ()
{
    ((IS_ALLOW_TRAP_SET)) || return 0
    # 1: set 0: unset
    local trap_local_vars_set_or_unset="${1}"
    shift
    local trap_local_vars_vars_name=("${@}")
    local trap_local_vars_var
    for trap_local_vars_var in "${trap_local_vars_vars_name[@]}" ; do
        if ((trap_local_vars_set_or_unset)) ; then
            TRAP_LOCAL_VARS["$trap_local_vars_var"]=1
        else
            [[ "${TRAP_LOCAL_VARS["$trap_local_vars_var"]+set}" == 'set' ]] && {
                # 如果发现hash表中有对应键取消掉
                unset 'TRAP_LOCAL_VARS[$trap_local_vars_var]'
            }
        fi
    done
    return 0
}

return 0

