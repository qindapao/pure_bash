. ./meta/meta.sh
((DEFENSE_VARIABLES[str_tr_cr_to_space]++)) && return 0

# 1: 输入字符串
# :TODO: 进程替换后会丢失掉结尾换行符,如果介意,用printf -v
str_tr_cr_to_space ()
{
    case "$#" in
    0)
    local ori_str=
    IFS= read -d '' -r ori_str || true
    printf "%s" "${ori_str//[$'\n\r']/ }"
    ;;
    1)
    eval -- $1='${!1//[$'\''\n\r'\'']/ }'
    ;;
    *)
    eval -- $1[\$2]='${3//[$'\''\n\r'\'']/ }'
    ;;
    esac
}

return 0

