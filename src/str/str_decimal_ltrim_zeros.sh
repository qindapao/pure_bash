. ./meta/meta.sh
((DEFENSE_VARIABLES[str_decimal_ltrim_zeros]++)) && return 0

# 只有合法的数字才能用这个函数,所以要先判断是合法的10进制
# 如果最后的结果有正号是会被去掉的
str_decimal_ltrim_zeros () 
{ 
    if [[ -n "$3" ]] ; then
        eval -- "$3=\$(( \${2%%[!+-]*}10#\${2#[-+]} ))"
    else
        printf "%s" $(( ${2%%[!+-]*}10#${2#[-+]} ))
    fi
}

alias str_decimal_ltrim_zeros_s='str_decimal_ltrim_zeros ""'

return 0

