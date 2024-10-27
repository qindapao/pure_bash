. ./meta/meta.sh
((DEFENSE_VARIABLES[str_ltrim_zeros]++)) && return 0

# 去掉前导0(如果单纯只有一个0需要保留)
str_ltrim_zeros ()
{
    # extglob实现
    # shopt -s extglob ; printf -v _str_ltrim_zeros_out_str "%s" "${2##+(0)}"
    case "$#" in
    0)
    local ori_str= cnv_str=
    IFS= read -d '' -r ori_str || true
    printf -v cnv_str "%s" "${ori_str#"${ori_str%%[!0]*}"}"
    if [[ -z "$cnv_str" ]] ; then
        printf "%s" "${ori_str:0:1}"
    else
        printf "%s" "${cnv_str}"
    fi
    ;;
    1)
    set -- "$1" "${!1#"${!1%%[!0]*}"}"
    if [[ -z "$2" ]] ; then
        eval -- $1='${!1:0:1}'
    else
        eval -- $1='$2'
    fi
    ;;
    *)
    set -- "$1" "$2" "$3" "${3#"${3%%[!0]*}"}"
    if [[ -z "$4" ]] ; then
        eval -- $1[\$2]='${3:0:1}'
    else
        eval -- $1[\$2]='${4}'
    fi
    ;;
    esac
}

return 0

