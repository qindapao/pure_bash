. ./meta/meta.sh
((DEFENSE_VARIABLES[str_decimal_ltrim_zeros]++)) && return 0

# 只有合法的数字才能用这个函数,所以要先判断是合法的10进制
# 如果最后的结果有正号是会被去掉的
# 可用于高阶函数和管道
str_decimal_ltrim_zeros () 
{ 
    case "$#" in
    0)
    local dec_str=
    IFS= read -d '' -r dec_str || true
    printf "%s" $(( ${dec_str%%[!+-]*}10#${dec_str#[-+]} ))
    ;;
    1)
    eval -- "$1=\$(( \${!1%%[!+-]*}10#\${!1#[-+]} ))"
    ;;
    *)
    eval -- $1[\$2]='$(( ${3%%[!+-]*}10#${3#[-+]} ))'
    ;;
    esac
}

return 0

