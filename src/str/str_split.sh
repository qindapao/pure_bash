. ./meta/meta.sh
((DEFENSE_VARIABLES[str_split]++)) && return 0

# 字符串拆分函数,只是对awk的封装,功能多,支持连续分隔符和global
# 由于要开新进程,效率一般
# :TODO: 如果想支持从文件中读取,可以把最后一个参数设计成文件名(最后一个参数并且索引是奇数)
# $ echo "1:xx;yy:12;kk:" | str_split ':' 2 ';' 2
# yy
str_split ()
{
    local input_str
    read -d '' input_str
    local output="$input_str"

    while (($#)) ; do
        local delimiter="${1}"
        local field_number="${2}"
        
        output=$(awk -F "$delimiter" "{print \$$field_number}" < <(printf "%s" "$output"))
        (($#)) && shift
        (($#)) && shift
    done
    
    printf "%s" "$output"
}

return 0

