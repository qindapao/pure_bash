. ./meta/meta.sh
((DEFENSE_VARIABLES[str_trim]++)) && return 0

# 去掉行首和行尾空白字符
# Usage: trim_s "   example   string    "
# :TODO: $(str_trim x str1) 进程替换后会丢失结尾换行符,如果介意用printf -v
str_trim ()
{
    # 陷阱导致$_不准确,所以不使用:这种形式
    # : "${2#"${2%%[![:space:]]*}"}"
    local tmp_str="${2#"${2%%[![:space:]]*}"}"
    printf "%s" "${tmp_str%"${_##*[![:space:]]}"}"
}

# 使用shopt -s extglob
# str_trim ()
# {
#     local tmp_str=${2##+([[:space:]])}
#     printf "%s" "${tmp_str%%+([[:space:]])}"
# }

alias str_trim_s='str_trim ""'

return 0

