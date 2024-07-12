. ./meta/meta.sh
((DEFENSE_VARIABLES[str_split]++)) && return 0

# 字符串拆分函数,只是对awk的封装,功能多,支持连续分隔符和global
# 由于要开新进程,效率一般
# $ echo "1:xx;yy:12;kk:" | str_split_pipe ':' 2 ';' 2
# $ str_split_pipe xx.txt ':' 2 ';' 2
# yy
# 函数本体是给高阶函数使用
str_split ()
{
    local input_str=''
    read -d '' input_str < "${2:-/dev/stdin}"
    shift 2
    local output="$input_str"

    while (($#)) ; do
        local delimiter=$1 field_number=$2
        
        # :TODO: 嵌入式环境中< <()语法可能失效,提示没有相关的文件描述符
        output=$(awk -F "$delimiter" "{print \$$field_number}" < <(printf "%s" "$output"))
        (($#)) && shift
        (($#)) && shift
    done
    
    printf "%s" "$output"
}

# 管道使用
alias str_split_pipe='str_split "" ""'
# 文件使用
alias str_split_file='str_split ""'

return 0

