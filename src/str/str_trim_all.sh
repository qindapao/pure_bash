. ./meta/meta.sh
((DEFENSE_VARIABLES[str_trim_all]++)) && return 0

. ./str/str_to_array.sh || return 1

# 1: 需要改变的变量名
str_trim_all ()
{
    # 防止命名冲突
    case "$#" in
    1)
    declare -a str_arr_${1}
    str_to_array str_arr_${1} "${!1}"
    eval -- ''$1'="${str_arr_'$1'[*]}"'
    ;;
    *) # 数组名 索引 值
    declare -a str_arr_${1}
    str_to_array str_arr_${1} "${3}"
    eval -- $1[\$2]='${str_arr_'$1'[*]}'
    ;;
    esac
}

return 0

