. ./meta/meta.sh
((DEFENSE_VARIABLES[set_intersection]++)) && return 0

. ./set/set_init.sh || return 1
. ./set/set_add.sh || return 1
. ./set/set_remove.sh || return 1
. ./set/set_contains.sh || return 1

# 求若干个集合的交集
# 1: 交集保存集合的变量名
# @: 求交集的所有集合的变量名列表
#
# 返回值:
#   0: 返回正常
#   1: 第一个参数未初始化成关联数组
#
#   注意: 为了避免空键,集合中的元素都加了前缀x
#   所以要取集合应该使用
#   x=("${!set[@]}")
#   去掉每个数组元素的第一个字符
#   real=("${x[@]#?}")
set_intersection ()
{ 
    local -n _set_intersection_ref_result_set=$1
    local -n _set_intersection_tmp_hash=$2
    local _set_intersection_key

    # 如果不是关联数组报错
    [[ "${_set_intersection_ref_result_set@a}" != *A* ]] && return 1
    set_init '_set_intersection_ref_result_set'

    for _set_intersection_key in "${!_set_intersection_tmp_hash[@]}"; do
        set_add '_set_intersection_ref_result_set' "${_set_intersection_key:1}"
    done

    shift 2

    while(($#)) ; do
        local -n _set_intersection_tmp_hash=$1
        for _set_intersection_key in "${!_set_intersection_ref_result_set[@]}" ; do
            set_contains '_set_intersection_tmp_hash' "${_set_intersection_key:1}" || {
                set_remove '_set_intersection_ref_result_set' "${_set_intersection_key:1}"
            }
        done

        shift
    done

    return 0
}

return 0

