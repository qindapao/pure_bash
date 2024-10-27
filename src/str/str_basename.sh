. ./meta/meta.sh
((DEFENSE_VARIABLES[str_basename]++)) && return 0

# 从文件路径字符串中解析文件名(不带后缀)
# 直接更新原字符串
# 可用于cntr_map函数
str_basename () 
{ 
    case "$#" in
    0)
    local ori_str=
    IFS= read -d '' -r ori_str || true
    ori_str=${ori_str##*/}
    printf "%s" "${ori_str%%.*}"
    ;;
    1) # 普通字符串
    eval -- $1='${!1##*/}'
    eval -- $1='${!1%%.*}'
    ;;
    *) # 数组: 名字 键 值
    set -- "$1" "$2" "${3##*/}"
    eval -- $1[\$2]='${3%%.*}'
    ;;
    esac
}

return 0

