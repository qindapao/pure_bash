. ./meta/meta.sh
((DEFENSE_VARIABLES[file_del_end_blank_lines]++)) && return 0

# 删除文件末尾的连续空行
# sed实现
# cat other.txt  | file_del_end_blank_lines
# file_del_end_blank_lines other.txt
# /dev/stdin 文件是标准输入
# 只是 file_del_end_pattern 的一个特例而已
file_del_end_blank_lines () 
{ 
    sed '{
        :start
        /^[[:space:]]*$/{$d ; N ; b start }
    }'
} < "${1:-"$PURE_STDIN"}"

return 0

