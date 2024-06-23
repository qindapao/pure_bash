. ./meta/meta.sh
((DEFENSE_VARIABLES[str_abs_path]++)) && return 0

# 获取目录字符串中的完整路径(不带最后的斜杠)
# 用于带文件名的字符串
str_abs_path ()
{
    printf "%s" "${1%/*}"
}

return 0

