. ./meta/meta.sh
((DEFENSE_VARIABLES[str_to_array]++)) && return 0

# 字符串转换成数组(只支持单一的分隔符,但是可以传入多个,是或的关系)
# 1: 最后保存的数组名
# 2: 需要处理的字符串的值
# 3: 单一分隔符(如果不传就使用默认分隔符)
#       str_to_array out_arr "$in_str" '-+ '
#       表示使用-+或者空格作为单一分隔符来分隔字符串
# :TODO: 这个函数对于连续的分隔符会去掉,最后数组元素没有空元素
# 大部分情况下这是想要的结果,但是如果介意,可以使用mapfile或者read
# 命令来拆分
str_to_array ()
{
    local - ; set -f ; set +B
    local IFS="${3-${IFS}}"
    eval -- ''$1'=($2)'
}

return 0

