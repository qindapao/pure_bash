. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_unset_prefix]++)) && return 0

# 删除字典中以某个前缀开始的所有键
# 1: 待处理关联数组引用名
# 2: 需要删除的前缀
#
# 返回值:
#   1: 如果前缀为空
#   0: 正常的情况
dict_unset_prefix ()
{
    [[ "${2:+set}" ]] || return 1

    eval -- '
        for index_'$1' in "${!'$1'[@]}" ; do
            [[ "$index_'$1'" == "$2"* ]] && unset -v '\'''$1'[$index_'$1']'\''
        done
        '
    return 0
}

return 0

