. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_del_field]++)) && return 0

. ./log/log_dbg.sh || return 1

# 删除不需要指定键的类型
# struct_del_field 'struct_name' 'filed_name' 'key1' 0 4
# 结构体复合变量创建
# 第一级要么是一个数组要么是一个关联数组
struct_del_field ()
{
    local -n _struct_del_field_struct_ref="${1}"
    shift

    # 最简单的情况,删除顶级键
    if (($#==1)) ; then
        [[ -n "$1" ]] && unset '_struct_del_field_struct_ref["${1}"]'
        return
    fi

    # 不是顶级键的情况,从上到下查找
    eval local _struct_set_field_data_lev{1..20}=''
    # 记录每层需要更新的索引(0层不处理先占位)
    local -a _struct_del_field_index_lev=('')
    local _struct_del_field_index _struct_del_field_top_level_str=''
    local _struct_del_field_lev_cnt=1
    local _struct_del_field_index_first="${1}"
    local _struct_del_field_data_lev_ref_last=${_struct_del_field_struct_ref["$_struct_del_field_index_first"]}

    for _struct_del_field_index in "${@:2:$#}" ; do
        ((_struct_del_field_lev_cnt++))
        [[ -z "$_struct_del_field_index" ]] && return 1
        local -n _struct_del_field_data_lev_ref=_struct_set_field_data_lev${_struct_del_field_lev_cnt}
        
        # log_dbg d '' _struct_del_field_data_lev_ref_last

        # 转换上一个数据类型
        if [[ "$_struct_del_field_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ _struct_set_field_data_lev[0-9]+=(.*) ]] ; then
            declare ${BASH_REMATCH[2]} _struct_set_field_data_lev${_struct_del_field_lev_cnt}
            eval _struct_del_field_data_lev_ref="${BASH_REMATCH[3]}"
            # log_dbg d "_struct_set_field_data_lev${_struct_del_field_lev_cnt}" _struct_set_field_data_lev${_struct_del_field_lev_cnt}
        fi

        log_dbg d '' _struct_del_field_data_lev_ref _struct_del_field_index
        _struct_del_field_data_lev_ref_last="${_struct_del_field_data_lev_ref["$_struct_del_field_index"]}"

        _struct_del_field_index_lev+=("$_struct_del_field_index")
        # log_dbg d '' _struct_del_field_data_lev_ref
    done

    _struct_del_field_index_lev=('' "${_struct_del_field_index_lev[@]}")
    # log_dbg d '' _struct_del_field_index_lev 

    # log_dbg d "_struct_del_field_index_lev _struct_del_field_lev_cnt" _struct_del_field_index_lev _struct_del_field_lev_cnt

    # 删除最后一级,然后依次往上更新
    local -i _struct_del_field_is_not_last_lev=0
    while ((_struct_del_field_lev_cnt>2)) ; do
        # 取出当前层数据结构
        local -n _struct_del_field_data_lev_ref=_struct_set_field_data_lev$((_struct_del_field_lev_cnt-1))

        if ! ((_struct_del_field_is_not_last_lev++)) ; then
            # 删除底级键
            log_dbg d "_struct_del_field_data_lev_ref" _struct_del_field_data_lev_ref 
            unset '_struct_del_field_data_lev_ref[${_struct_del_field_index_lev[_struct_del_field_lev_cnt]}]'
        else
            # 如果上一级删除的结果导致了空数组或者空hash,那么继续删除
            if [[ -z "$_struct_del_field_top_level_str" ]] ; then
                unset '_struct_del_field_data_lev_ref[${_struct_del_field_index_lev[_struct_del_field_lev_cnt]}]'
            else
                # 如果不是空的,更新索引
                _struct_del_field_data_lev_ref["${_struct_del_field_index_lev[_struct_del_field_lev_cnt]}"]="$_struct_del_field_top_level_str"
            fi
        fi
        
        # 当前数据结果完整的序列化保存到_struct_del_field_top_level_str
        if((${#_struct_del_field_data_lev_ref[@]})) ; then
            _struct_del_field_top_level_str="${_struct_del_field_data_lev_ref[@]@A}"
        else
            _struct_del_field_top_level_str=''
        fi
        ((_struct_del_field_lev_cnt--))
    done
    
    # 查看是否需要删除顶级键
    if [[ -z "$_struct_del_field_top_level_str" ]] ; then
        unset '_struct_del_field_struct_ref["$_struct_del_field_index_first"]'
    else
        # 否则更新顶级键
        _struct_del_field_struct_ref["$_struct_del_field_index_first"]="$_struct_del_field_top_level_str"
    fi

    return 0
}

return 0

