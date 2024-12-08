. ./meta/meta.sh
((DEFENSE_VARIABLES[str_common_suffix]++)) && return 0

# 返回值: 上层作用域的REPLY变量
# 寻找两个字符串的最长公共前缀
# 返回值
# 0: 找到后缀
# 1: 没有找到后缀
str_common_suffix ()
{
    meta_var_clear REPLY
    local a=$1 b=$2
    ((${#a}>${#b})) && local a=$b b=$a
    b=${b:${#b}-${#a}}
    if [[ $a == "$b" ]]; then
        REPLY=$a
        [[ "$REPLY" ]]
        return $?
    fi

    local l=0 u=${#a} m
    while ((l+1<u)); do
        ((m=(l+u+1)/2))
        if [[ ${a:m} == "${b:m}" ]]; then
            ((u=m))
        else
            ((l=m))
        fi
    done

    REPLY=${a:u}
    [[ "$REPLY" ]]
}

return 0

