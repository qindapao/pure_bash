. ./meta/meta.sh
((DEFENSE_VARIABLES[str_rtrim]++)) && return 0

# 去掉行尾空白字符
str_rtrim ()
{
    case "$#" in
    0)
    local ori_str=
    IFS= read -d '' -r ori_str || true
    printf "%s" "${ori_str%"${ori_str##*[![:space:]]}"}"
    ;;
    1)
    eval -- $1='${!1%"${!1##*[![:space:]]}"}'
    ;;
    *)
    eval -- $1[\$2]='${3%"${3##*[![:space:]]}"}'
    ;;
    esac
}

return 0

