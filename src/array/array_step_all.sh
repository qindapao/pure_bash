. ./meta/meta.sh
((DEFENSE_VARIABLES[array_step_all]++)) && return 0

. ./atom/atom_func_reverse_params.sh || return 1
. ./array/array_step.sh || return 1

# 实现数组的步进(可以同时生成多个步进子数组)
# 1: 原数组
# 2 5 8  ...: 多组子数组名
# 3 6 9  ...: 步进开始索引
# 4 7 10 ...: 步进值
array_step_all ()
{
    atom_func_reverse_params
    while (($#-1)) ; do
        eval -- "array_step \"\${$#}\"" \"\$3\" \"\$2\" \"\$1\"
        shift 3
    done

    return 0
}

return 0

