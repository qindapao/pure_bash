# 为了防止有引用变量的情况下的变量污染,所有带引用变量的库函数都以_函数名_打头
# 所有 : 的函数都是暂时未实现的

. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_set_intersection]++)) && return 0

. ./array/array_none.sh || return 1

# :TODO: 关于集合的4个操作是否需要处理数组的情况？(数组去重后当集合用?还是用hash键比较好,天生不重复)
# 处理集合的时候注意下,集合可能不只要处理两个,可能是超过2个
# 所有的数组都必须是关联数组(需要在传进函数前声明好)
# hash模拟集合的交集
# 1: 最终交集保存的hash引用
# @: 所有求交集的hash引用
dict_set_intersection ()
{
    local -n _dict_set_intersection_ref_result_hash="${1}"
    local -n _dict_set_intersection_tmp_hash="${2}"
    local _dict_set_intersection_key

    for _dict_set_intersection_key in "${!_dict_set_intersection_tmp_hash[@]}"; do
        _dict_set_intersection_ref_result_hash["$_dict_set_intersection_key"]=1
    done

    shift 2

    while(($#)) ; do
        local -n _dict_set_intersection_tmp_hash="${1}"
        local -a _dict_set_intersection_indexs=("${!_dict_set_intersection_tmp_hash[@]}")
        for _dict_set_intersection_key in "${!_dict_set_intersection_ref_result_hash[@]}" ; do
            # 为了防止命令扩展下面使用的是单引号,奇怪的是这里单引号可以展开变量,并且防止意外的命令执行,双引号反而不行,但是这种写法在cygwin虚拟环境上无法执行
            # [[ -v _dict_set_intersection_tmp_hash['$_dict_set_intersection_key'] ]] || unset '_dict_set_intersection_ref_result_hash["$_dict_set_intersection_key"]'
            # 换一种更笨的方法,首尾加空格为了防止非全匹配和首尾缺失空格的问题(性能降低但是所有环境可用)
            if array_none _dict_set_intersection_indexs str_is_equa "$_dict_set_intersection_key" ; then
                # unset中的最外层的单引号是必要的,防止索引被意外解析,索引中的双引号可有可无
                unset '_dict_set_intersection_ref_result_hash["$_dict_set_intersection_key"]'
            fi
        done
        (($#)) && shift
    done
}

return 0

