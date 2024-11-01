. ./meta/meta.sh
((DEFENSE_VARIABLES[str_quote]++)) && return 0

# 得到引用字符串
str_quote ()
{
    case "$#" in
    0)
    local ori_str=
    IFS= read -d '' -r ori_str || true
    printf "%s" "${ori_str@Q}"
    ;;
    1)
    eval -- $1='${!1@Q}'
    ;;
    *)
    eval -- $1[\$2]='${3@Q}'
    ;;
    esac
}

return 0

