. ./meta/meta.sh
((DEFENSE_VARIABLES[awk_grep_after_nb]++)) && return 0

# nb的意思是no border 没有边界
awk_grep_after_nb () {
    local grep_str="$1" deal_file="${2:--}"
    awk -v a="$grep_str" '$0 ~ a && !found {found=1; next} found' "$deal_file"
}

return 0

