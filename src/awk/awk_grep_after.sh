. ./meta/meta.sh
((DEFENSE_VARIABLES[awk_grep_after]++)) && return 0

awk_grep_after () {
    # 提供文件就是文件,否则标准输入
    local grep_str="$1" deal_file="${2:--}"
    # 最后的found是一个条件表达式用来判断条件是否为真就打印行
    awk -v a="$grep_str" '$0 ~ a {found=1} found' "$deal_file"
}

return 0

