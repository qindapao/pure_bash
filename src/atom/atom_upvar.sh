. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_upvar]++)) && return 0

# :TODO: 扩展支持关联数组的返回?
# 注意: 如果是引用变量就不要用这个函数
# 用法: 
#
#    f() { local b; g b; echo $b; }
#    g() { local "$1" && upvar $1 bar; }
#    f  # Ok: b=bar
atom_upvar() 
{
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}

return 0

