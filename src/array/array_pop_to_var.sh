. ./meta/meta.sh
((DEFENSE_VARIABLES[array_pop_to_var]++)) && return 0

# 弹出数组的元素到一系列变量中
# 1~#-1: 变量名字
# $#:    数组的名字
array_pop_to_var ()
{
    while(($#-1)) ; do
        eval -- eval -- $1='\${$'$#'[-1]}'
        eval -- unset -v '$'$#'[-1]'
        shift
    done
}

return 0

