# 字典操作集合(模拟perl5的行为)

# 为了防止有引用变量的情况下的变量污染,所有带引用变量的库函数都以_函数名_打头
# 所有 : 的函数都是暂时未实现的

. ./meta.sh
((DEFENSE_VARIABLES[dict]++)) && return

. ./atom.sh
. ./str.sh

# 保持hash的值不重复(这个好像意义不大)
dict_uniq ()
{
    local -n _dict_uniq_ref_arr="${1}"
    local -n _dict_uniq_ref_out_arr="${2}"

    local -A _dict_uniq_element_hash=()
    local _dict_uniq_i

    for _dict_uniq_i in "${!_dict_uniq_ref_arr[@]}" ; do
        local _dict_uniq_tmp_key="${_dict_uniq_ref_arr["$_dict_uniq_i"]}"
        # :TODO: 值为空的直接排除是否合理?
        [[ -z "$_dict_uniq_tmp_key" ]] && continue
        if [[ -z "${_dict_uniq_element_hash["$_dict_uniq_tmp_key"]}" ]] ; then
            _dict_uniq_element_hash["$_dict_uniq_tmp_key"]=1
            _dict_uniq_ref_out_arr["$_dict_uniq_i"]="$_dict_uniq_tmp_key"
        fi
    done
}

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
            if dict_none _dict_set_intersection_indexs str_is_equa "$_dict_set_intersection_key" ; then
                # unset中的最外层的单引号是必要的,防止索引被意外解析,索引中的双引号可有可无
                unset '_dict_set_intersection_ref_result_hash["$_dict_set_intersection_key"]'
            fi
        done
        (($#)) && shift
    done
}

# hash模拟集合的并集
dict_set_union ()
{
    local -n _dict_set_union_ref_result_hash="${1}"
    shift

    local _dict_set_union_key
    
    while(($#)) ; do
        local -n _dict_set_union_tmp_hash="${1}"
        for _dict_set_union_key in "${!_dict_set_union_tmp_hash[@]}" ; do
            _dict_set_union_ref_result_hash["$_dict_set_union_key"]=1
        done
        
        (($#)) && shift
    done
}

# hash模拟集合的差集
array_set_diff ()
{
    :
}

# hash模拟集合的补集
array_set_complement ()
{
    :
}

# 字典grep,如果有元素查找到,返回真,否则返回假
# 不改变原始的字典
dict_grep ()
{
    local -n _dict_grep_ref_dict="${1}" _dict_grep_ref_out_dict="${2}"
    _dict_grep_ref_out_dict=()
    local _dict_grep_function="${3}"
    shift 3
    local -a _dict_grep_params=("${@}")
    local _dict_grep_i
    
    for _dict_grep_i in "${!_dict_grep_ref_dict[@]}" ; do
        if "$_dict_grep_function" "${_dict_grep_ref_dict["$_dict_grep_i"]}" "$_dict_grep_i" "${_dict_grep_params[@]}"  ; then
            _dict_grep_ref_out_dict["$_dict_grep_i"]="${_dict_grep_ref_dict["$_dict_grep_i"]}"
        fi
    done
    
    ((${#_dict_grep_ref_out_dict[@]})) && return 0 || return 1
}

# 使用匿名代码块来进行过滤
dict_grep_block ()
{
    local -n _dict_grep_block_ref_dict="${1}" _dict_grep_block_out_dict="${2}"
    _dict_grep_block_out_dict=()
    local _dict_grep_block_exec_block="${3}"

    eval "_dict_grep_block_tmp_function() { "$_dict_grep_block_exec_block" ; }"
    local _dict_grep_block_index

    for _dict_grep_block_index in "${!_dict_grep_block_ref_dict[@]}" ; do
        if _dict_grep_block_tmp_function "${_dict_grep_block_ref_dict["$_dict_grep_block_index"]}" "$_dict_grep_block_index" ; then
            _dict_grep_block_out_dict["$_dict_grep_block_index"]="${_dict_grep_block_ref_dict["$_dict_grep_block_index"]}"
        fi
    done

    unset -f _dict_grep_block_tmp_function

    ((${#_dict_grep_ref_out_arr[@]})) && return 0 || return 1
}

# 判断一个数据结构是否是一个数组(不管是否是引用都能正确处理)
# 1: 需要判断的数组的名字
dict_is_dict ()
{
    atom_identify_data_type "${1}" "A" && return 0 || return 1
}


