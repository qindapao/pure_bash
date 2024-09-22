. ./meta/meta.sh
((DEFENSE_VARIABLES[file_del_pattern]++)) && return 0

# 删除文件中所有包含某个模式的行
# 两种用法
# file_del_pattern other.txt '^[[:space:]]*$' | file_del_end_pattern '' '^[[:space:]]*return[[:space:]]*0[[:space:]]*$'
# /dev/stdin 文件是标准输入
file_del_pattern () 
{ 
    local -a map_file=()
    mapfile -t map_file  < "${1:-"$PURE_STDIN"}"
    local pattern=$2
    local tmp_line=
    
    for tmp_line in "${map_file[@]}" ; do
        [[ "$tmp_line" =~ $pattern ]] || printf "%s\n" "$tmp_line"
    done
}

# awk实现版本
# file_del_pattern () { awk '!/'$2'/' < "${1:-"$PURE_STDIN"}" ; }

alias file_del_pattern_pipe='file_del_pattern ""'

return 0

