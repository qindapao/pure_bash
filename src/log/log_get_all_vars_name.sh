. ./meta/meta.sh
((DEFENSE_VARIABLES[log_get_all_vars_name]++)) && return 0

. ./array/array_del_elements_dense.sh || return 1

log_get_all_vars_name ()
{
    local -n _dbg_get_all_vars_name_ref_array="$1"
    # declare -p 不跟变量打印所有变量和赋值表达式和值
    mapfile -t _dbg_get_all_vars_name_ref_array < <(compgen -A variable)
    array_del_elements_dense _dbg_get_all_vars_name_ref_array '_dbg_get_all_vars_name_ref_array'
    return 0
}

return 0

