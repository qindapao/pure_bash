. ./meta/meta.sh
((DEFENSE_VARIABLES[json_del]++)) && return 0

. ./base64/base64_decode.sh || return 1
. ./json/json_common.sh || return 1
. ./json/json_pack.sh || return 1
. ./log/log_dbg.sh || return 1
. ./regex/regex_common.sh || return 1

# LOG_LEVEL=2

# :TODO: 中间的索引删除后会造成数组空洞,可能需要解决,因为python是没有稀疏数组的
# 如果保留稀疏数组,那么可能python的交互可能存在问题

# 删除不需要指定键的类型
# json_del 'json_name' 'key1' 0 4
# 结构体复合变量创建
# 第一级要么是一个数组要么是一个关联数组
# 
# 返回值:
#   bit0: 传入的参数中有空字符串
#   bit1: 原始键是非关联数组,但是想要获取的是字符串键
#   bit2: 键不存在
json_del ()
{
    local -n _json_del_json_ref=$1
    shift

    # 不是顶级键的情况,从上到下查找
    # 记录每层需要更新的索引(0 1层不处理先占位)
    local -a _json_del_index_lev=('' '')
    local _json_del_{index,top_level_str="",lev_cnt=1,index_first="$1"}

    [[ -z "$_json_del_index_first" ]] && return ${JSON_COMMON_ERR_DEFINE[del_null_key]}
    if [[ "${_json_del_json_ref@a}" != *A* ]] && ! [[ "${_json_del_index_first}" =~ $REGEX_COMMON_UINT_DECIMAL ]] ; then
        return ${JSON_COMMON_ERR_DEFINE[del_key_but_not_dict]}
    fi

    if [[ ! -v '_json_del_json_ref[$_json_del_index_first]' ]] ; then
        return ${JSON_COMMON_ERR_DEFINE[del_key_not_fount]}
    fi

    local _json_del_data_lev_ref_last=${_json_del_json_ref["$_json_del_index_first"]}
    local _json_del_delate_key='' _json_del_declare_flag=''

    for _json_del_index in "${@:2:$#}" ; do
        ((_json_del_lev_cnt++))
        [[ -z "$_json_del_index" ]] && return ${JSON_COMMON_ERR_DEFINE[del_null_key]}
        # :TODO: 这里的local是否多余?
        local ${JSON_COMMON_MAGIC_STR}${_json_del_lev_cnt}=''
        local -n _json_del_data_lev_ref=${JSON_COMMON_MAGIC_STR}${_json_del_lev_cnt}
        
        # 转换上一个数据类型
        if [[ "$_json_del_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ ${JSON_COMMON_MAGIC_STR}[0-9]+=(.*) ]] ; then
            declare ${BASH_REMATCH[2]} ${JSON_COMMON_MAGIC_STR}${_json_del_lev_cnt}
            ((JSON_COMMON_SERIALIZATION_ALGORITHM==JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin])) && {
                eval _json_del_data_lev_ref="${BASH_REMATCH[3]}" ; } || {
                    base64_decode _json_del_data_lev_ref "${BASH_REMATCH[3]}" 
                    eval _json_del_data_lev_ref="$_json_del_data_lev_ref" ; }
            _json_del_declare_flag="${BASH_REMATCH[2]}"   
        else
            _json_del_declare_flag=''
        fi

        if [[ "$_json_del_declare_flag" != *A* ]] && ! [[ "${_json_del_index}" =~ $REGEX_COMMON_UINT_DECIMAL ]] ; then
            return ${JSON_COMMON_ERR_DEFINE[del_key_but_not_dict]}
        fi

        if [[ -v '_json_del_data_lev_ref[$_json_del_index]' ]] ; then
            _json_del_data_lev_ref_last="${_json_del_data_lev_ref["$_json_del_index"]}"
            _json_del_index_lev+=("$_json_del_index")
        else
            return ${JSON_COMMON_ERR_DEFINE[del_key_not_fount]}
        fi
    done

    # 删除最后一级,然后依次往上更新
    local -i _json_del_is_not_last_lev=0
    while ((_json_del_lev_cnt>1)) ; do
        # 取出当前层数据结构
        local -n _json_del_data_lev_ref=${JSON_COMMON_MAGIC_STR}${_json_del_lev_cnt}

        _json_del_delate_key="${_json_del_index_lev[_json_del_lev_cnt]}"
        if ! ((_json_del_is_not_last_lev++)) ; then
            # 删除底级键
            # 索引最后如果不是数字,那么需要一个中间变量转换键,不然''无法使用
            # ${_json_del_index_lev[_json_del_lev_cnt]} 这个如果是一个字符串,那么
            # unset '_json_del_data_lev_ref[${_json_del_index_lev[_json_del_lev_cnt]}]' 这个语法是会报错的
            # 但是如果不用单引号保护,有些复杂字符串会出问题,并且单引号中就不要用双引号了(如果用了索引数组会出问题)
            # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# b="xxx\ xxx-\>xxx-\>xxx-\>xx:xx.x-\>\(xxx:xx\)-\>\(xxxxx:xxxx\)"
            # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# eval "c=$b"
            # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# declare -p c
            # declare -- c="xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"
            # 比如上面这个复杂字符串
            # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash# 
            unset -v '_json_del_data_lev_ref[$_json_del_delate_key]'
        else
            # 如果上一级删除的结果导致了空数组或者空hash,那么继续删除
            if [[ -z "$_json_del_top_level_str" ]] ; then
                unset -v '_json_del_data_lev_ref[$_json_del_delate_key]'
            else
                # 如果不是空的,更新索引
                _json_del_data_lev_ref["$_json_del_delate_key"]="$_json_del_top_level_str"
            fi
        fi
        
        # 当前数据结果完整的序列化保存到_json_del_top_level_str
        if((${#_json_del_data_lev_ref[@]})) ; then
            json_pack_o '_json_del_data_lev_ref' '_json_del_top_level_str' "${JSON_COMMON_MAGIC_STR}${_json_del_lev_cnt}"
        else
            _json_del_top_level_str=''
        fi
        ((_json_del_lev_cnt--))
    done
    
    # 查看是否需要删除顶级键
    if [[ -z "$_json_del_top_level_str" ]] ; then
        unset -v '_json_del_json_ref[$_json_del_index_first]'
    else
        # 否则更新顶级键
        _json_del_json_ref["$_json_del_index_first"]="$_json_del_top_level_str"
    fi

    return ${JSON_COMMON_ERR_DEFINE[ok]}
}

return 0

