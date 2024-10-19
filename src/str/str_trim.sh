. ./meta/meta.sh
((DEFENSE_VARIABLES[str_trim]++)) && return 0

# 去掉行首和行尾空白字符
# 1: 需要trim的字符串名
str_trim ()
{
    case "$#" in
    1)
    eval -- $1='${!1#"${!1%%[![:space:]]*}"}'
    eval -- $1='${!1%"${!1##*[![:space:]]}"}'
    ;;
    *)
    set -- "$1" "$2" "${3#"${3%%[![:space:]]*}"}"
    eval -- $1[\$2]='${3%"${3##*[![:space:]]}"}'
    esac
}

return 0

