. ./meta/meta.sh
((DEFENSE_VARIABLES[str_startswith]++)) && return 0

. ./atom/atom_my.sh || return 1

# 字符串以什么开头(满足返回true,否则返回false,大小写敏感)
# 1: 如果字符串在一个数组中,那么这个数组的索引(主要是为了高阶函数)
# 2: 需要检查的字符串
# 3: 需要检查的前缀
# 4: 是否忽略大小写(默认不忽略)
# 5: 字符串开始索引[可选,如果没有就是从0开始]
# 6: 字符串结束索引[可选,如果没有就是在最大结束]
str_startswith () 
{
    # 这里赋值不需要用双引号保护(只有位置参数有效),并且这里大括号是必须保留的
    my {index,in_str,prefix,is_ignore_case}=\${$((i++))}
    
    ((is_ignore_case)) && { in_str=${in_str,,} ; prefix=${prefix,,} ; }
    local start_pos="${5:-0}"
    local str_len=${#in_str}
    local end_pos="${6:-${str_len}}"

    # 如果开始或结束位置是负数，则从字符串末尾开始计算
    ((start_pos<0)) && ((start_pos+=str_len))
    ((end_pos<0))   && ((end_pos+=str_len))

    # 检查索引范围是否有效
    ((start_pos>=str_len || start_pos<0)) && return 1

    # 调整结束索引，如果超出字符串长度则设置为字符串长度
    ((end_pos>str_len)) && ((end_pos=str_len))

    # 如果结束索引小于开始索引，返回假
    ((end_pos<start_pos)) && return 1

    # 提取子字符串
    local sub_str="${in_str:start_pos:end_pos-start_pos}"

    # 检查子字符串是否以前缀开始
    [[ "$sub_str" == "$prefix"* ]]
}

alias str_startswith_s='str_startswith ""'

return 0

