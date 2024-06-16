. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_del_field]++)) && return 0

. ./log/log_dbg.sh || return 1

# 删除不需要指定键的类型
# struct_del_field 'struct_name' 'filed_name' 'key1' 0 4
# 结构体复合变量创建
# 第一级要么是一个数组要么是一个关联数组
# 返回值:
#   bit0: 外部传入的键是空键
#   bit1: 外部传入的键无法找到索引
struct_del_field ()
{
    local -n _struct_del_field_struct_ref="${1}"
    shift
    local -i _struct_del_field_ret=0

    # 最简单的情况,删除顶级键
    if (($#==1)) ; then
        if [[ -n "$1" ]] ; then
            if [[ -v '_struct_del_field_struct_ref["${1}"]' ]] ; then
                unset '_struct_del_field_struct_ref["${1}"]'
            else
                ((_struct_del_field_ret|=2))
            fi
        else
            ((_struct_del_field_ret|=1))
        fi
        return $_struct_del_field_ret
    fi

    # 不是顶级键的情况,从上到下查找
    eval local _struct_set_field_data_lev{1..20}=''
    # 记录每层需要更新的索引(0层不处理先占位)
    local -a _struct_del_field_index_lev=('')
    local _struct_del_field_index _struct_del_field_top_level_str=''
    local _struct_del_field_lev_cnt=1

    local -i _struct_del_field_is_not_first_lev=0

    for _struct_del_field_index in "${@:1:$#}" ; do
        ((_struct_del_field_lev_cnt++))
        [[ -z "$_struct_del_field_index" ]] && {
            ((_struct_del_field_ret|=1))
            return $_struct_del_field_ret
        }
        local -n _struct_del_field_data_lev_ref=_struct_set_field_data_lev${_struct_del_field_lev_cnt}

        # 转换上一个数据类型
        if ((_struct_del_field_is_not_first_lev++)) ; then
            if [[ "$_struct_del_field_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ _struct_set_field_data_lev[0-9]+=(.*) ]] ; then
                declare ${BASH_REMATCH[2]} _struct_set_field_data_lev${_struct_del_field_lev_cnt}
                eval _struct_del_field_data_lev_ref="${BASH_REMATCH[3]}"
            fi
            _struct_del_field_data_lev_ref_last="${_struct_del_field_data_lev_ref["$_struct_del_field_index"]}"
        else
            _struct_del_field_data_lev_ref_last="${_struct_del_field_struct_ref["$_struct_del_field_index"]}"
        fi

        log_dbg d '' _struct_del_field_data_lev_ref _struct_del_field_index

        _struct_del_field_index_lev+=("$_struct_del_field_index")
    done

    log_dbg d '' _struct_del_field_index_lev

    # 删除最后一级,然后依次往上更新
    local -i _struct_del_field_is_not_last_lev=0
    while ((_struct_del_field_lev_cnt>2)) ; do
        # 取出当前层数据结构
        local -n _struct_del_field_data_lev_ref=_struct_set_field_data_lev$((_struct_del_field_lev_cnt-1))

        if ! ((_struct_del_field_is_not_last_lev++)) ; then
            # 删除底级键
            if [[ -v '_struct_del_field_data_lev_ref[${_struct_del_field_index_lev[_struct_del_field_lev_cnt]}]' ]] ; then
                unset '_struct_del_field_data_lev_ref[${_struct_del_field_index_lev[_struct_del_field_lev_cnt]}]'
            else
                ((_struct_del_field_ret|=2))
            fi
        else
            # 如果上一级删除的结果导致了空数组或者空hash,那么继续删除
            if [[ -z "$_struct_del_field_top_level_str" ]] ; then
                # 里面不要加双引号

                if [[ -v '_struct_del_field_data_lev_ref[${_struct_del_field_index_lev[_struct_del_field_lev_cnt]}]' ]] ; then
                    unset '_struct_del_field_data_lev_ref[${_struct_del_field_index_lev[_struct_del_field_lev_cnt]}]'
                else
                    ((_struct_del_field_ret|=2))
                fi
            else
                # 如果没有导致空数组或者空hash,那么需要更新当前层级对应键(因为内容已经改变)
                if [[ -v '_struct_del_field_data_lev_ref[${_struct_del_field_index_lev[_struct_del_field_lev_cnt]}]' ]] ; then
                    _struct_del_field_data_lev_ref["${_struct_del_field_index_lev[_struct_del_field_lev_cnt]}"]="$_struct_del_field_top_level_str"
                else
                    ((_struct_del_field_ret|=2))
                fi
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
    
    # 只要有任何错误发生,都不能更新顶级键(防止数据被错误篡改)
    ((_struct_del_field_ret)) && return $_struct_del_field_ret

    # 查看是否需要删除顶级键
    if [[ -z "$_struct_del_field_top_level_str" ]] ; then
        if [[ -v '_struct_del_field_struct_ref["$_struct_del_field_index_first"]' ]] ; then
            unset '_struct_del_field_struct_ref[$_struct_del_field_index_first]'
        else
            ((_struct_del_field_ret|=2))
        fi
    else
        # 否则更新顶级键
        _struct_del_field_struct_ref["$_struct_del_field_index_first"]="$_struct_del_field_top_level_str"
    fi

    return $_struct_del_field_ret
}

return 0

