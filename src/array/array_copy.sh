. ./meta/meta.sh
((DEFENSE_VARIABLES[array_copy]++)) && return 0

. ./atom/atom_is_varname_valid.sh || return 1

# 拷贝一个数组到另外一个数组中
# $1 $2: 把$2数组拷贝到$1
# 这个函数可以支持关联数组
# :TODO: 后面这种带eval的函数最好都提前进行参数检查，如果发现格式不复合要求
# 需要提前报错
array_copy ()
{
    atom_is_varname_valid "$1" "$2" || return 1
    local _array_copy_script_${1}${2}='
        '$1'=()
        local i'$1$2'
        for i'$1$2' in "${!'$2'[@]}"; do
          '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
        done'
    eval -- eval -- \"\$"_array_copy_script_${1}${2}"\"
    true
}

# 下面是设置IFS为空的版本,但是上面的更好,调试eval执行代码最好的方式是使用
# set -xv选项看到bash代码展开和执行的细节
# array_copy ()
# {
#     local IFS='' 
#     local _array_copy_script_${1}${2}='
#         '$1'=()
#         local i'$1$2'
#         for i'$1$2' in "${!'$2'[@]}"; do
#           '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
#         done'

#     # 只有在IFS=''的时候才可以正常工作
#     # 如果只有一个eval就没有这个要求
#     # 需要确保字符串中的空格不会被解释为分隔符。因此，设置 IFS='' 
#     # 可以避免潜在的问题。
#     eval -- eval -- "$"_array_copy_script_${1}${2}""
# }

return 0

