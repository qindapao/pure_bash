. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_map]++)) && return 0

. ./cntr/cntr_common.sh || return 1

# 参数:
#   1: 需要map的数组或者关联数组名
#   2: map子函数/别名/代码块
# 子函数最多3个参数
# 变量名 键 值
# map_func ()
# {
#     eval $1[\$2]='${3}x'
# }
# block调用模板
# array_map COM_LOGS "echo '$1' | tee -a \$3"

# 变量初始化的地方
cntr_map ()
{
    local _cntr_map_script$1="${CNTR_TEMPLATE_GENERATE_TEMP_FUNC_BEFORE//NAME/$1}"
    local _cntr_map_script$1+="$2"
    local _cntr_map_script$1+="${CNTR_TEMPLATE_GENERATE_TEMP_FUNC_AFTER//NAME/$1}"
    local _cntr_map_script$1+='
    local i'$1'
    for i'$1' in "${!'$1'[@]}" ; do
        eval "$2" '\'''$1''\'' '\''"${i'$1'}"'\'' '\''"${'$1'[$i'$1']}"'\''
    done
    '
    local _cntr_map_script$1+="${CNTR_TEMPLATE_DEL_TEMP_FUNC//NAME/$1}"

    eval -- eval -- '"${_cntr_map_script'$1'}"'
}

return 0

