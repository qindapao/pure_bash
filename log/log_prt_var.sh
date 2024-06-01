. ./meta/meta.sh
((DEFENSE_VARIABLES[log_prt_var]++)) && return 0


# 因为我们有map函数,所以并不需要打印一系列变量的函数
# 打印一个变量(转换变量为可打印格式并且移除引号)
# 1: 变量名称字符串
# 2: 为高阶函数预留的index
# 3: 是否转换换行符为空格(默认转换)
# 4: 输出的分隔符(默认为空格)
log_prt_var ()
{
    local prt_var_info=''
    prt_var_info=$(declare -p "${1}" 2>/dev/null)
    local is_tr_cr_to_space="${3:-1}"
    local separator="${4:- }"
    
    if [[ -z "$prt_var_info" ]] ; then
        prt_var_info="${1}="
    elif [[ "$prt_var_info" =~ ^declare\ [-a-zA-Z]+\ ([^=]+=.+) ]] ; then
        prt_var_info="${BASH_REMATCH[1]}"

        ((is_tr_cr_to_space)) && { 
            prt_var_info="${prt_var_info//$'\n'/ }"
            prt_var_info="${prt_var_info//$'\r'/ }"
        }

        prt_var_info="${prt_var_info//\'/}"
        prt_var_info="${prt_var_info//\"/}"
    else
        prt_var_info="${1}="
    fi
    prt_var_info+="$separator"
    printf "%s" "$prt_var_info"
}

return 0

