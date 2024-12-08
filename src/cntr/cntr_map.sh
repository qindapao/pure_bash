. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_map]++)) && return 0

. ./cntr/cntr_common.sh || return 1

# 参数:
#   1: 需要map的数组或者关联数组名
#   2: map子函数/别名/代码块
#   3~@:
#       子函数中可以带参数
# 子函数最多3个参数
# 变量名 键 值
# map_func ()
# {
#     eval $1[\$2]='${3}x'
# }
# block调用模板
# array_map COM_LOGS "echo '$1' | tee -a \$3"
# array_map COM_LOGS 'echo "$4" | tee -a "$3"' "$1"
# 更新记录:
#   2024.11.15 别名手动展开(bash4.4 别名定义和查找：别名是在命令行读取时进行扩展的，而不是在执行时)
#              比较高的版本的bash改进了这个行为,别名在执行函数时候也会扩展
#              为了兼容bash4.4,我们先设置手动扩展
#              别名带参数的情况需要先转换成数组再执行
#              root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# alias lsl='ls -l " xx yy"'
#              root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# eval mx=(${BASH_ALIASES[lsl]})
#              root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p mx
#              declare -a mx=([0]="ls" [1]="-l" [2]=" xx yy")
#              root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# mx=(${BASH_ALIASES[lsl]})
#              root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p mx
#              declare -a mx=([0]="ls" [1]="-l" [2]="\"" [3]="xx" [4]="yy\"")
#              root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# #

# 变量初始化的地方
cntr_map ()
{
    local _cntr_map_script$1="${CNTR_TEMPLATE_GENERATE_TEMP_FUNC_BEFORE//NAME/$1}"
    local _cntr_map_script$1+="$2"
    local _cntr_map_script$1+="${CNTR_TEMPLATE_GENERATE_TEMP_FUNC_AFTER//NAME/$1}"
    local _cntr_map_script$1+='
    local i'$1'
    local alias_arr'$1'
    for i'$1' in "${!'$1'[@]}" ; do
        if [[ "${BASH_ALIASES[$2]:+set}" ]] ; then
            if [[ -o noglob ]] ; then
                eval alias_arr'$1'=(${BASH_ALIASES[$2]})
            else
                local - ; set -f ; eval alias_arr'$1'=(${BASH_ALIASES[$2]}) ; set +f
            fi
            eval "${alias_arr'$1'[@]}" '\'''$1''\'' '\''"${i'$1'}"'\'' '\''"${'$1'[$i'$1']}"'\'' '\''"${@:3}"'\''
        else
            eval "$2" '\'''$1''\'' '\''"${i'$1'}"'\'' '\''"${'$1'[$i'$1']}"'\'' '\''"${@:3}"'\''
        fi
    done
    '
    local _cntr_map_script$1+="${CNTR_TEMPLATE_DEL_TEMP_FUNC//NAME/$1}"

    eval -- eval -- '"${_cntr_map_script'$1'}"'
}

return 0

