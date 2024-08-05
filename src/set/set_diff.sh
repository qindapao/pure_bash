. ./meta/meta.sh
((DEFENSE_VARIABLES[set_diff]++)) && return 0

# 求两个集合的差集
# 1: 大集合
# 2: 小集合
# 3: 差集的集合
set_diff ()
{
    eval -- ''$3'=()'
    eval -- 'local index_'$1$2$3''
    eval -- '
        for index_'$1$2$3' in "${!'$1'[@]}" ; do
            if [[ ! "${'$2'[$index_'$1$2$3']+set}" ]] ; then
                '$3'[$index_'$1$2$3']=${'$1'[$index_'$1$2$3']}
            fi
        done
        '
    
    return 0
}

return 0

