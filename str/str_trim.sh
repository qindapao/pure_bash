. ./meta/meta.sh
((DEFENSE_VARIABLES[str_trim]++)) && return 0

# 去掉行首和行尾空白字符
# Usage: trim_s "   example   string    "
str_trim ()
{
    : "${1#"${1%%[![:space:]]*}"}"
    printf "%s" "${_%"${_##*[![:space:]]}"}"
}

return 0

