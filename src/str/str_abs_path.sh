. ./meta/meta.sh
((DEFENSE_VARIABLES[str_abs_path]++)) && return 0

# 获取目录字符串中的完整路径(不带最后的斜杠)
# 用于带文件名的字符串
# 可用于cntr_map函数
str_abs_path () 
{ 
    case "$#" in
    0)
    local ori_str=
    IFS= read -d '' -r ori_str || true
    printf "%s" "${ori_str%/*}"
    ;;
    1)
    eval -- $1='${!1%/*}'
    ;;
    *)
    eval -- $1[\$2]='${3%/*}'
    ;;
    esac
}

return 0

