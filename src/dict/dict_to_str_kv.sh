. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_to_str_kv]++)) && return 0

. ./dict/dict_to_kv.sh || return 1

# 把一个关联数组变成一个kv字符串,引用包裹,中间空格
# 1: kv字符串的变量名
# 2: 关联数组的变量名
dict_to_str_kv ()
{ 
    eval -- '
        local -a a'$1$2'=()
        dict_to_kv a'$1$2' '$2'
        '$1'=${a'$1$2'[*]@Q}
    '
}

return 0

