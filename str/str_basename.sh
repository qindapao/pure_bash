. ./meta/meta.sh
((DEFENSE_VARIABLES[str_basename]++)) && return 0

# 从文件路径字符串中解析文件名(不带后缀)
str_basename ()
{
    local out_str="${1##*/}"
    printf "%s" "${out_str%%.*}"
}

return 0

