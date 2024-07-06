. ./meta/meta.sh
((DEFENSE_VARIABLES[array_epop]++)) && return 0

# 删除数组(致密数组)的最后一个元素并且保存到变量中
# array_epop "arr_name" 'ret'
# 上面这样使用是不行的, 由于子shell中执行所以值不会变
array_epop ()
{
    eval "local i$1=\$((\${#$1[@]}-1))"
    ((i$1<0)) && return 1
    eval "$2=\"\${$1[i$1]}\""
    unset -v "$1[i$1]"
    return 0
}

return 0

