. ./meta/meta.sh
((DEFENSE_VARIABLES[str_dirname]++)) && return 0


# 获取目录字符串中的当前目录名
# 用于带文件名的字符串
# 可以用于高阶函数
str_dirname ()
{
    case "$#" in
    0)
    local ori_str=
    IFS= read -d '' -r ori_str || true
    ori_str=${ori_str%/*}
    printf "%s" "${ori_str##*/}"
    ;;
    1) # 普通字符串
    eval -- $1='${!1%/*}'
    eval -- $1='${!1##*/}'
    ;;
    *) # 数组: 名字 键 值
    set -- "$1" "$2" "${3%/*}"
    eval -- $1[\$2]='${3##*/}'
    ;;
    esac

}

return 0

