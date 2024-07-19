. ./meta/meta.sh
((DEFENSE_VARIABLES[str_trim_all]++)) && return 0

. ./str/str_to_array.sh || return 1

# 去掉行首行尾所有空格，中间的所有空白保留一个空格
# 传入字符串名字原地修改
# str="  geg gge         geg          "
# Usage: str_trim_all "" "str"
#        str_trim_all_s "str"
# 注意: 这里str不能传递引用变量
# :TODO: 含有eval的改变外部变量的函数都要检查下是否有命名冲突风险
str_trim_all ()
{
    # 防止命名冲突
    declare -a str_arr_${2}
    str_to_array str_arr_${2} "${!2}"
    eval -- ''$2'="${str_arr_'$2'[*]}"'
}

alias str_trim_all_s='str_trim_all ""'

return 0

