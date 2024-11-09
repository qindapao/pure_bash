. ./meta/meta.sh
((DEFENSE_VARIABLES[str_common]++)) && return 0

# 字符串的原型模板
STR_PROTOTYPE='        '

# 预留字符串原型(保证原型字符串的长度足够)
str_common_reserve_prototype ()
{
    local n=$1 c
    for ((c=${#STR_PROTOTYPE};c<n;c*=2)); do
        STR_PROTOTYPE=$STR_PROTOTYPE$STR_PROTOTYPE
    done
}

# 生成重复字符串
# 1: 重复内容
# 2: 字符串重复次数
# 返回:
# ret_str 上层变量
str_common_repeat ()
{
    str_common_reserve_prototype "$2"
    ret_str=${STR_PROTOTYPE::$2}
    ret_str=${ret_str// /"$1"}
}

return 0

