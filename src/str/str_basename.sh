. ./meta/meta.sh
((DEFENSE_VARIABLES[str_basename]++)) && return 0

# 从文件路径字符串中解析文件名(不带后缀)
str_basename ()
{
    local out_str=${2##*/}
    printf "%s" "${out_str%%.*}"
}

# 另外一种使用extglob的实现
# shopt -s extglob
# str_basename () { printf "%s" "${2//@(*\/|.*)}" ; }

# 带s的是直接使用的,上面的是在高阶函数中的
alias str_basename_s='str_basename ""'

return 0

