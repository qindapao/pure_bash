. ./meta/meta.sh
((DEFENSE_VARIABLES[str_common_prefix]++)) && return 0

# 返回值: 上层作用域的REPLY变量
# 寻找两个字符串的最长公共前缀
str_common_prefix ()
{
    meta_var_clear REPLY
    local a=$1 b=$2
    ((${#a}>${#b})) && local a=$b b=$a
    b=${b::${#a}}
    if [[ $a == "$b" ]]; then
        REPLY=$a
        [[ "$REPLY" ]]
        return $?
    fi

    local l=0 u=${#a} m
    while ((l+1<u)); do
      ((m=(l+u)/2))
      if [[ ${a::m} == "${b::m}" ]]; then
        ((l=m))
      else
        ((u=m))
      fi
    done

    REPLY=${a::l}
    [[ "$REPLY" ]]
}

return 0

