. ./meta/meta.sh
((DEFENSE_VARIABLES[file_del_end_pattern]++)) && return 0

# 删除文件末尾的包含某个模式的行
# 两种用法
# file_del_end_pattern other.txt '^\s*$' | file_del_end_pattern '' '^\s*return\s*0\s*$'
# /dev/fd/0 文件是标准输入
file_del_end_pattern () 
{ 
    local -a map_file=()
    mapfile -t map_file  < "${1:-/dev/fd/0}"
    local pattern="${2}"
    local tmp_line=
    while ((${#map_file[@]})) ; do
        tmp_line=${map_file[-1]}
        # 检查是否匹配模式
        if [[ "$tmp_line" =~ $pattern ]] ; then
            unset map_file[-1]
        else
            break
        fi
    done

    # 输出
    printf "%s\n" "${map_file[@]}"
}

return 0

