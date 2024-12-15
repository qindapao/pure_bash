. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_by_kv]++)) && return 0

# 通过一个kv数组重新生成关联数组
# 1: 关联数组的变量名
# 2: kv数组的变量名(数组必须是置密的)
dict_by_kv ()
{ 
    eval -- '
    local i'$1$2'
    for ((i'$1$2'=0;i'$1$2'<${#'$2'[@]};i'$1$2'+=2)) ; do
        '$1'[${'$2'[i'$1$2']}]=${'$2'[i'$1$2'+1]}
    done
    '
}

return 0

