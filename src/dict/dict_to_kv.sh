. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_to_kv]++)) && return 0

# 把一个关联数组变成一个kv数组
# 1: kv数组的变量名
# 2: 关联数组的变量名
dict_to_kv ()
{ 
    eval -- '
    local e'$1$2'
    for e'$1$2' in "${!'$2'[@]}" ; do
        '$1'+=("${e'$1$2'}" "${'$2'[${e'$1$2'}]}")
    done
    '
}

return 0

