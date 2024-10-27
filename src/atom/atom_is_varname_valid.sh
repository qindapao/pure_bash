. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_is_varname_valid]++)) && return 0

# 正则实现
atom_is_varname_valid () 
{ 
    local varname
    for varname in "${@}" ; do
        [[ "$varname" =~ ^[a-zA-Z_]+[a-zA-Z0-9_]*$ ]] || return 1
    done
    return 0
}

return 0

