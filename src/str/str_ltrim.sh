. ./meta/meta.sh
((DEFENSE_VARIABLES[str_ltrim]++)) && return 0

# 去掉行首空白字符
# 可用于cntr_grep
str_ltrim ()
{
    case "$#" in
    0)
    local ori_str=
    IFS= read -d '' -r ori_str || true
    printf "%s" "${ori_str#"${ori_str%%[![:space:]]*}"}"
    ;;
    1)
    eval -- $1='${!1#"${!1%%[![:space:]]*}"}'
    ;;
    *)
    eval -- $1[\$2]='${3#"${3%%[![:space:]]*}"}'
    ;;
    esac
}

return 0

