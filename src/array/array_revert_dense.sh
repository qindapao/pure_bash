. ./meta/meta.sh
((DEFENSE_VARIABLES[array_revert_dense]++)) && return 0


# 忽略数组的索引翻转数组
# 原地翻转1个数组
array_revert_dense ()
{
    eval -- '((${#'$1'[@]})) || return 0'
    eval -- 'local -a tmp_'$1'=("${'$1'[@]}")'
    eval -- 'local -i tmp_'$1'_max_index=$((${#tmp_'$1'[@]}-1))'
    eval -- eval -- eval -- 'set -- \\\"'$1'\\\" \\\"$\\{tmp_'$1'[{$tmp_'$1'_max_index..0}]\\}\\\"'
    eval -- ''$1'=("${@:2}")'
    return 0
}

return 0

