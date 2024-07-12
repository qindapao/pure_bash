. ./meta/meta.sh
((DEFENSE_VARIABLES[array_uniq_multi]++)) && return 0

. ./array/array_uniq.sh || return 1

# 去重多个数组中的重复元素,并且更新原数组,不保留原始的index
array_uniq_multi ()
{
    while(($#)) ; do
        local -n _array_uniq_multi_ref_arr=$1
        array_uniq _array_uniq_multi_ref_arr
        shift
    done
}

return 0

