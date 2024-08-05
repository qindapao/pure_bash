. ./meta/meta.sh
((DEFENSE_VARIABLES[str_split]++)) && return 0

# 使用block的方式在高阶函数中使用该函数
# 字符串拆分函数,只是对awk的封装,功能多,支持连续分隔符和global
# 由于要开新进程,效率一般
# $ echo "1:xx;yy:12;kk:" | str_split_pipe ':' 2 ';' 2
# $ str_split_pipe xx.txt ':' 2 ';' 2
# yy
str_split ()
{
    local input_str=''
    case $1 in
        -i)
        # 从标准输入读取数据
        read -r -d '' input_str || true
        shift
        ;;
        -s)
        # 从字符串读取数据
        input_str=$2
        shift 2
        ;;
        -f)
        # 从文件读取数据
        read -r -d '' input_str < "$2" || true
        shift 2
        ;;
    esac

    local output="$input_str"

    while (($#)) ; do
        local delimiter=$1 field_number=$2
        
        # bash会自动处理<<<添加到末尾的换行符
        output=$(awk -F "$delimiter" "{print \$$field_number}" <<<$(printf "%s" "$output"))
        (($#)) && shift
        (($#)) && shift
    done
    
    printf "%s" "$output"
}

# 管道使用
alias str_split_i='str_split "-i"'
# 文件使用
alias str_split_f='str_split "-f"'
# 字符串
alias str_split_s='str_split "-s"'

return 0

