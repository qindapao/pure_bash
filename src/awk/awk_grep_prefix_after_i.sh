. ./meta/meta.sh
((DEFENSE_VARIABLES[awk_grep_prefix_after]++)) && return 0

awk_grep_prefix_after () 
{ 
    # 提供文件就是文件,否则标准输入
    local grep_prefix_str="$1" deal_file="${2:--}"
    awk -v a="$grep_prefix_str" 'index(tolower($0), tolower(a)) == 1 {found=1} found' "$deal_file"
}

return 0

