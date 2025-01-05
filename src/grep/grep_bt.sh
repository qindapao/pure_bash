. ./meta/meta.sh
((DEFENSE_VARIABLES[grep_bt]++)) && return 0

. ./str/str_to_array.sh || return 1

# 抓取两个标签中间的所有内容,所有的匹配都保存到数组中
# 匹配的标签可能有多对
# <mac>mac1</mac><mac>mac2</mac>
# 
# 下面正则表达式的详细解释
# grep -oP '(?i)<mac>\K.*?(?=</mac>)' "$tmp_file"
# (?i)<mac>\K.*?(?=</mac>)。这个表达式用于从XML文件中提取<mac>标签内的内容。下面是每个部分的具体解释：
#
# (?i): 
#   这个部分启用了不区分大小写的模式。也就是说，它会匹配<MAC>、<mac>、<Mac>等各种大小写组合。
# <mac>: 
#   这个部分匹配<mac>标签的开头。
# \K: 
#   这是一个特殊的断言，它会重置匹配的起始位置。在这个表达式中，<mac>标签匹配之后，\K会让匹配从标签后的内容开始，这样标签本身不会被包含在最终的匹配结果中。
# .*?: 
#   这部分是一个非贪婪匹配，用于匹配任意数量的任意字符，但尽可能少地匹配。这里的*表示匹配0次或多次，?使其成为非贪婪匹配，即尽量少匹配字符。
# (?=</mac>): 
#   这个部分是一个正向肯定预查，意思是匹配必须以</mac>标签结尾，但不包括这个标签本身。它确保匹配到的内容在</mac>标签之前结束。
#
# 总结一下，这个正则表达式的整体作用是：
#   1. 启用不区分大小写模式。
#   2. 从开头找到<mac>标签。
#   3. 只捕获<mac>标签和</mac>标签之间的内容，不包含标签本身。

grep_bt ()
{
    REPLY=''
    local tag_begin=$1
    local tag_end=$2
    local file_path=${3:--}
    local is_ignorecase=${4:-0}
    local is_in_param_str=${5:-0}
    local perl_regex=''
    ((is_ignorecase)) && perl_regex+='(?i)'
    perl_regex+="$tag_begin"'\K.*?(?='"$tag_end"')'
    local fit_list=
    if ((is_in_param_str)) ; then
        fit_list=$(printf "%s" "$file_path" | grep -oP "$perl_regex")
    else
        fit_list=$(grep -oP "$perl_regex" "$file_path")
    fi
    local -a out_arr=()
    str_to_array out_arr "$fit_list" $'\n'
    REPLY="${out_arr[*]@Q}"
}

return 0

