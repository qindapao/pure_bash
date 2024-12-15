. ./meta/meta.sh
((DEFENSE_VARIABLES[array_dec_from_str]++)) && return 0

# :TODO: 这个函数的效率并不高，如果字符串太长还是要用grep工具

# 从一个字符串中抓取所有的10进制数字并且保存到数组中
# 1: 保存的数组名
# 2: 待处理的字符串的值
array_dec_from_str ()
{
    eval -- '
    '$1'=()
    local tmp_'$1'=$2
    while [[ "${tmp_'$1'}" =~ ^[^0-9]*([0-9]+) ]] ; do
        '$1'+=("${BASH_REMATCH[1]}")
        tmp_'$1'=${tmp_'$1'#*"${BASH_REMATCH[0]}"}
    done
    '
}

return 0

