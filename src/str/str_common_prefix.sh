. ./meta/meta.sh
((DEFENSE_VARIABLES[str_common_prefix]++)) && return 0

# 返回值: 上层作用域的ret_str_common_prefix变量
# 寻找两个字符串的最长公共前缀
str_common_prefix ()
{
    meta_var_clear ret_str_common_prefix
    local a=$1 b=$2
    ((${#a}>${#b})) && local a=$b b=$a
    b=${b::${#a}}
    if [[ $a == "$b" ]]; then
        ret_str_common_prefix=$a
        [[ "$ret_str_common_prefix" ]]
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

    ret_str_common_prefix=${a::l}
    [[ "$ret_str_common_prefix" ]]
}

return 0

