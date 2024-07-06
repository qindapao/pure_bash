. ./meta/meta.sh
((DEFENSE_VARIABLES[file_del_pattern]++)) && return 0

# 删除文件中所有包含某个模式的行
# 两种用法
# file_del_pattern other.txt '^\s*$' | file_del_end_pattern '' '^\s*return\s*0\s*$'
# /dev/fd/0 文件是标准输入
file_del_pattern () 
{ 
    local -a map_file=()
    mapfile -t map_file  < "${1:-/dev/fd/0}"
    local pattern="${2}"
    local tmp_line=
    
    for tmp_line in "${map_file[@]}" ; do
        [[ "$tmp_line" =~ $pattern ]] || printf "%s\n" "$tmp_line"
    done
}

return 0

