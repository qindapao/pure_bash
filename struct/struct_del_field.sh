. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_del_field]++)) && return 0

# . ./log/log_dbg.sh || return 1

# LOG_LEVEL=2

# 删除不需要指定键的类型
# struct_del_field 'struct_name' 'key1' 0 4
# 结构体复合变量创建
# 第一级要么是一个数组要么是一个关联数组
# 
# 返回值:
#   bit0: 传入的参数中有空字符串
#   bit1: 原始键是非关联数组,但是想要获取的是字符串键
#   bit2: 键不存在
struct_del_field ()
{
    local -n _struct_del_field_struct_ref="${1}"
    shift

    # 不是顶级键的情况,从上到下查找
    # 记录每层需要更新的索引(0 1层不处理先占位)
    local -a _struct_del_field_index_lev=('' '')
    local _struct_del_field_index _struct_del_field_top_level_str=''
    local _struct_del_field_lev_cnt=1
    local _struct_del_field_index_first="${1}"

    [[ -z "$_struct_del_field_index_first" ]] && return 1
    if [[ "${_struct_del_field_struct_ref@a}" != *A* ]] && ! [[ "${_struct_del_field_index_first}" =~ ^[1-9][0-9]*$|^0$ ]] ; then
        return 2
    fi

    if [[ ! -v '_struct_del_field_struct_ref[$_struct_del_field_index_first]' ]] ; then
        return 4
    fi

    local _struct_del_field_data_lev_ref_last=${_struct_del_field_struct_ref["$_struct_del_field_index_first"]}
    local _struct_del_field_delate_key='' _struct_del_field_declare_flag=''

    for _struct_del_field_index in "${@:2:$#}" ; do
        ((_struct_del_field_lev_cnt++))
        [[ -z "$_struct_del_field_index" ]] && return 1
        # :TODO: 这里的local是否多余?
        local _struct_set_field_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev${_struct_del_field_lev_cnt}=''
        local -n _struct_del_field_data_lev_ref=_struct_set_field_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev${_struct_del_field_lev_cnt}
        
        # 转换上一个数据类型
        if [[ "$_struct_del_field_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ _struct_set_field_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev[0-9]+=(.*) ]] ; then
            declare ${BASH_REMATCH[2]} _struct_set_field_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev${_struct_del_field_lev_cnt}
            eval _struct_del_field_data_lev_ref="${BASH_REMATCH[3]}"
            _struct_del_field_declare_flag="${BASH_REMATCH[2]}"   
        else
            _struct_del_field_declare_flag=''
        fi

        if [[ "$_struct_del_field_declare_flag" != *A* ]] && ! [[ "${_struct_del_field_index}" =~ ^[1-9][0-9]*$|^0$ ]] ; then
            return 2
        fi

        if [[ -v '_struct_del_field_data_lev_ref[$_struct_del_field_index]' ]] ; then
            _struct_del_field_data_lev_ref_last="${_struct_del_field_data_lev_ref["$_struct_del_field_index"]}"
            _struct_del_field_index_lev+=("$_struct_del_field_index")
        else
            return 4
        fi
    done

    # 删除最后一级,然后依次往上更新
    local -i _struct_del_field_is_not_last_lev=0
    while ((_struct_del_field_lev_cnt>1)) ; do
        # 取出当前层数据结构
        local -n _struct_del_field_data_lev_ref=_struct_set_field_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev${_struct_del_field_lev_cnt}

        _struct_del_field_delate_key="${_struct_del_field_index_lev[_struct_del_field_lev_cnt]}"
        if ! ((_struct_del_field_is_not_last_lev++)) ; then
            # 删除底级键
            # 索引最后如果不是数字,那么需要一个中间变量转换键,不然''无法使用
            # ${_struct_del_field_index_lev[_struct_del_field_lev_cnt]} 这个如果是一个字符串,那么
            # unset '_struct_del_field_data_lev_ref[${_struct_del_field_index_lev[_struct_del_field_lev_cnt]}]' 这个语法是会报错的
            # 但是如果不用单引号保护,有些复杂字符串会出问题,并且单引号中就不要用双引号了(如果用了索引数组会出问题)
            # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# b="xxx\ xxx-\>xxx-\>xxx-\>xx:xx.x-\>\(xxx:xx\)-\>\(xxxxx:xxxx\)"
            # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# eval "c=$b"
            # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p c
            # declare -- c="xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"
            # 比如上面这个复杂字符串
            # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
            unset '_struct_del_field_data_lev_ref[$_struct_del_field_delate_key]'
        else
            # 如果上一级删除的结果导致了空数组或者空hash,那么继续删除
            if [[ -z "$_struct_del_field_top_level_str" ]] ; then
                unset '_struct_del_field_data_lev_ref[$_struct_del_field_delate_key]'
            else
                # 如果不是空的,更新索引
                _struct_del_field_data_lev_ref["$_struct_del_field_delate_key"]="$_struct_del_field_top_level_str"
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
        unset '_struct_del_field_struct_ref[$_struct_del_field_index_first]'
    else
        # 否则更新顶级键
        _struct_del_field_struct_ref["$_struct_del_field_index_first"]="$_struct_del_field_top_level_str"
    fi

    return 0
}

return 0

