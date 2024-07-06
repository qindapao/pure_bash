. ./meta/meta.sh
((DEFENSE_VARIABLES[trap_global_vars]++)) && return 0


# 用一个全局的HASH表的键保存所有的需要陷阱函数打印的全局变量的值(值可以动态更新,方便调试)
# 陷阱函数无法打印函数的局部变量的值
# 基本用法是这样的
# 全局变量可以在脚本一开始就指定
# XX1=1
# XX2=2
# trap_global_vars 1 XX1 XX2
declare -gA TRAP_GLOBAL_VARS=()

trap_global_vars ()
{
    ((IS_ALLOW_TRAP_SET)) || return 0
    # 1: set 0: unset
    local trap_global_vars_set_or_unset="${1}"
    shift
    local trap_global_vars_vars_name=("${@}")
    local trap_global_vars_var
    for trap_global_vars_var in "${trap_global_vars_vars_name[@]}" ; do
        if ((trap_global_vars_set_or_unset)) ; then
            TRAP_GLOBAL_VARS["$trap_global_vars_var"]=1
        else
            [[ "${TRAP_GLOBAL_VARS["$trap_global_vars_var"]+set}" ]] && {
                # 如果发现hash表中有对应键取消掉
                unset 'TRAP_GLOBAL_VARS[$trap_global_vars_var]'
            }
        fi
    done
    return 0
}

return 0

