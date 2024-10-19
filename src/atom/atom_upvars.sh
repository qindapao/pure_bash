. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_upvars]++)) && return 0

atom_upvars_dict ()
{
    local _atom_upvars_script_${1}='
        NAME=() ; shift
        while (($#)) ; do NAME[${1}]="${2}" ; shift 2 ; done'
    eval -- eval -- '"${_atom_upvars_script_'$1'//NAME/$1}"'
}

# :TODO: 这种方法并没有在递归中测试过,谨慎使用!
# :TODO: 或者说要谨慎使用递归!
# :TODO: 验证下数组的@k操作符的引入版本
#
# 注意: 调用链中有引用变量不要用这个函数!
# Assign variables one scope above the caller
# Usage: local varname [varname ...] && 
#        upvars [-v varname value] | [-aN varname [value ...]] ...
# Available OPTIONS:
#     -aN  Assign next N values to varname as array
#     -v   Assign single value to varname
#     -AN  Assign next 2N values(key-value) to varname as association array
# Return: 1 if error occurs
# Example:
#
#    f() { local a b; g a b; declare -p a b; }
#    g() {
#        local c=( foo bar )
#        local "$1" "$2" && upvars -v $1 A -a${#c[@]} $2 "${c[@]}"
#    }
#    f  # Ok: a=A, b=(foo bar)
atom_upvars() 
{
    while (( $# )); do
        case $1 in
        -a*)
        # Assign array of -aN elements
        [[ "$2" ]] && unset -v "$2" &&
        eval $2=\(\"\${@:3:${1#-a}}\"\) && 
        shift $((${1#-a}+2))
        ;;
        -v)
        # Assign single value
        [[ "$2" ]] && unset -v "$2" &&
        eval $2=\"\$3\" &&
        shift 3
        ;;
        -A*)
        # Assign association array of -AN elements
        [[ "$2" ]] && unset -v "$2" && {
            atom_upvars_dict "$2" "${@:3:${1#-A}*2}"
            shift $((${1#-A}*2+2))
        }
        ;;
        esac
    done
}


return 0

