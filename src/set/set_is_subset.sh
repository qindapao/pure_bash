. ./meta/meta.sh
((DEFENSE_VARIABLES[set_is_subset]++)) && return 0

# 判断一个集合是否是另外一个集合的子集
# 1: 大集合
# 2: 小集合(判断它是否是大集合的子集)
set_is_subset ()
{
    # 空集是任何集合的子集
    eval -- '((${#'$2'[@]})) || return 0'
    eval -- 'local index_'$1'_'$2''
    eval -- '
        for index_'$1'_'$2' in "${!'$2'[@]}" ; do
            [[ "${'$1'[$index_'$1'_'$2']+set}" ]] || return 1
        done'
    return 0
}

return 0

