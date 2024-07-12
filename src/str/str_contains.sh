. ./meta/meta.sh
((DEFENSE_VARIABLES[str_contains]++)) && return 0

# 判断一个字符串是否是另外一个子字符串
# 1: 打桩的参数(高阶函数调用中传入的数组索引)
# 2: 需要判断的字符串
# 3: 判断是否包含的字符串
# 4: 是否忽略大小写
#       1: 忽略
#       0: 不忽略(默认)
str_contains ()
{
    # 这个是一个索引,一般用于map函数中
    local arr_index=$1 long_str=$2 short_str=$3 is_ignore_case=${4:-0}
    
    ((is_ignore_case)) && {
        long_str="${long_str,,}"
        short_str="${short_str,,}"
    }

    [[ "$long_str" == *"$short_str"* ]]
}

alias str_contains_s='str_contains ""'

return 0

