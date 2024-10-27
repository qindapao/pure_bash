. ./meta/meta.sh
((DEFENSE_VARIABLES[str_trim_all]++)) && return 0

. ./str/str_to_array.sh || return 1

# 1: 需要改变的变量名
# 删除行首行尾空白,中间的空格只保留一个
str_trim_all ()
{
    # 防止命名冲突
    case "$#" in
    0)
    local ori_str=
    IFS= read -d '' -r ori_str || true
    local -a str_arr
    str_to_array str_arr "${ori_str}"
    printf "%s" "${str_arr[*]}"
    ;;
    1)
    local -a str_arr_${1}
    str_to_array str_arr_${1} "${!1}"
    eval -- ''$1'="${str_arr_'$1'[*]}"'
    ;;
    *) # 数组名 索引 值
    local -a str_arr_${1}
    str_to_array str_arr_${1} "${3}"
    eval -- $1[\$2]='${str_arr_'$1'[*]}'
    ;;
    esac
}

return 0

