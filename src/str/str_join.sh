. ./meta/meta.sh
((DEFENSE_VARIABLES[str_join]++)) && return 0

# 不能用于管道
# 暂时不实现cntr_map函数的调用,因为似乎没有什么意义
# 场景1:链接的结果保存到一个变量中
#   str_join -v var_name '--' "${array[@]}"
# 场景2:cntr_map函数(暂时未实现)
#   第一个参数一定是变量名,所以不可能是-v(用于区分)
#   cntr_map array json_str '--' 'str1' 'str2'
str_join ()
{
    local _str_join_script_$2='
    local cNAME=$3
    shift 3
    NAME="$1"
    (($#)) && shift
    while(($#)) ; do NAME+="${cNAME}$1" ; shift ; done
    '
    eval -- eval -- '"${_str_join_script_'$2'//NAME/$2}"'
}

return 0

