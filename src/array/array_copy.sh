. ./meta/meta.sh
((DEFENSE_VARIABLES[array_copy]++)) && return 0

# 拷贝一个数组到另外一个数组中
# 通过eval动态生成代码,作用于外部的变量
# 这种方式有时候比使用间接引用更加自然
# $1 $2: 把$2数组拷贝到$1
# 这个函数可以支持关联数组
array_copy ()
{
    local _array_copy_script='
        '$1'=()
        local i'$1$2'
        for i'$1$2' in "${!'$2'[@]}"; do
          '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
        done'
    eval -- "$_array_copy_script"
}

return 0

