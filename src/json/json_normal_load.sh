. ./meta/meta.sh
((DEFENSE_VARIABLES[json_normal_load]++)) && return 0

. ./json/json_common.sh || return 1
. ./json/json_overlay.sh || return 1
. ./json/json_set.sh || return 1

json_normal_load ()
{
    local -n _json_normal_load_key_values=$1
    local -n _json_normal_load_json_out_ref=$2

    ((${#_json_normal_load_key_values[@]})) || return ${JSON_COMMON_ERR_DEFINE[ok]}

    # 加载json,如果是扁平的同一层级的数组或者字典,生成数组或者字典后,使用overlay方式加载
    # 1. 如果元素数量小于4,直接set
    # 2. 元素数量大于等于4,除了最后两个元素外,前面的元素全部相同
    array_qsort _json_normal_load_key_values '>'
    _json_normal_load_key_values+=("'999'")

    local -a _json_normal_load_tmp_common_keys=()
    local -a _json_normal_load_current_common_keys=()
    local -a _json_normal_load_tmp_arr_iv=()
    local -A _json_normal_load_tmp_dict_kv=()
    local _json_normal_load_current_type=''

    local -i _json_normal_load_kv_num=0
    local _json_normal_load_iter
    local -a _json_normal_load_key_value_line=()

    # 在操作前二维数组已经经过了层级从小到大的排列了,所以不存在会出现覆盖的情况
    # 1. common_keys中没有元素
    #   (1). 当前数量大于0小于4     => 直接set写
    #   (2). 当前数量大于等于4 => 写入common_keys,根据当前数据类型写入到临时数组或者字典中,并且更新_json_normal_load_current_type
    #   (3). 当前数量为0, 结束
    # 2. common_keys中有元素
    #   (1). 当前数量小于4但是大于0 => 先写common_keys中的overlay,然后清空三个临时数据结构;当前数据set写
    #   (2). 当前数量大于等于4
    #       [1]. 当前键在common_keys中,并且根据当前数据类型写入到临时数组或者字典中
    #       [2]. 当前键不在common_keys中，先写common_keys中的overlay,然后清空三个临时数据结构;压入
    #            common_keys中，并且根据当前数据类型写入到临时数组或者字典中,并且更新_json_normal_load_current_type
    #   (3). 当前数量为0 => 写common_keys中的overlay,结束

    # 每次写common_keys的overlay的原则是这样的:
    # 数据结构必须先从原来的_json_normal_load_json_out_ref中先取出来,然后再把新的加进去写入

    # :TODO: 缓存中的数据如果没有超过3对,都使用set而不是overlay

    for _json_normal_load_iter in "${_json_normal_load_key_values[@]}" ; do
        eval _json_normal_load_key_value_line=(${_json_normal_load_iter})
        _json_normal_load_key_value_line=("${_json_normal_load_key_value_line[@]:1}")
        _json_normal_load_kv_num=${#_json_normal_load_key_value_line[@]}

        if ((${#_json_normal_load_tmp_common_keys[@]})) ; then
            if ((_json_normal_load_kv_num<4)) && ((_json_normal_load_kv_num>0)) ; then
                if [[ "$_json_normal_load_current_type" == 'a' ]] ; then
                    json_overlay _json_normal_load_json_out_ref _json_normal_load_tmp_arr_iv "${_json_normal_load_tmp_common_keys[@]}"   
                else
                    json_overlay _json_normal_load_json_out_ref _json_normal_load_tmp_dict_kv "${_json_normal_load_tmp_common_keys[@]}"   
                fi
                _json_normal_load_tmp_common_keys=() _json_normal_load_tmp_arr_iv=() _json_normal_load_tmp_dict_kv=()
                json_set _json_normal_load_json_out_ref "${_json_normal_load_key_value_line[@]}"
            elif ((_json_normal_load_kv_num==0)) ; then
                if [[ "$_json_normal_load_current_type" == 'a' ]] ; then
                    json_overlay _json_normal_load_json_out_ref _json_normal_load_tmp_arr_iv "${_json_normal_load_tmp_common_keys[@]}"   
                else
                    json_overlay _json_normal_load_json_out_ref _json_normal_load_tmp_dict_kv "${_json_normal_load_tmp_common_keys[@]}"   
                fi
            else
                # 获取当前公共键
                _json_normal_load_current_common_keys=("${_json_normal_load_key_value_line[@]:0:_json_normal_load_kv_num-3}")
                if [[ "${_json_normal_load_current_common_keys[*]@Q}" == "${_json_normal_load_tmp_common_keys[*]@Q}" ]] ; then
                    if [[ "$_json_normal_load_current_type" == 'a' ]] ; then
                        _json_normal_load_tmp_arr_iv[${_json_normal_load_key_value_line[-3]}]="${_json_normal_load_key_value_line[-1]}"
                    else
                        _json_normal_load_tmp_dict_kv[${_json_normal_load_key_value_line[-3]:1:-1}]="${_json_normal_load_key_value_line[-1]}"
                    fi
                else
                    if [[ "$_json_normal_load_current_type" == 'a' ]] ; then
                        json_overlay _json_normal_load_json_out_ref _json_normal_load_tmp_arr_iv "${_json_normal_load_tmp_common_keys[@]}"   
                    else
                        json_overlay _json_normal_load_json_out_ref _json_normal_load_tmp_dict_kv "${_json_normal_load_tmp_common_keys[@]}"   
                    fi

                    _json_normal_load_tmp_common_keys=() _json_normal_load_tmp_arr_iv=() _json_normal_load_tmp_dict_kv=()
                    # 更新common_keys
                    _json_normal_load_tmp_common_keys=("${_json_normal_load_current_common_keys[@]}")
                    if [[ "${_json_normal_load_key_value_line[-3]: -1}" == ']' ]] ; then
                        _json_normal_load_current_type='A'
                        _json_normal_load_tmp_dict_kv[${_json_normal_load_key_value_line[-3]:1:-1}]="${_json_normal_load_key_value_line[-1]}"
                    else
                        _json_normal_load_current_type='a'
                        _json_normal_load_tmp_arr_iv[${_json_normal_load_key_value_line[-3]}]="${_json_normal_load_key_value_line[-1]}"
                    fi
                fi
            fi
        else
            if ((_json_normal_load_kv_num<4)) && ((_json_normal_load_kv_num>0)) ; then
                json_set _json_normal_load_json_out_ref "${_json_normal_load_key_value_line[@]}"
            elif ((_json_normal_load_kv_num==0)) ; then
                :
            else
                # 更新common_keys
                _json_normal_load_tmp_common_keys=("${_json_normal_load_key_value_line[@]:0:_json_normal_load_kv_num-3}")
                if [[ "${_json_normal_load_key_value_line[-3]: -1}" == ']' ]] ; then
                    _json_normal_load_current_type='A'
                    _json_normal_load_tmp_dict_kv[${_json_normal_load_key_value_line[-3]:1:-1}]="${_json_normal_load_key_value_line[-1]}"
                else
                    _json_normal_load_current_type='a'
                    _json_normal_load_tmp_arr_iv[${_json_normal_load_key_value_line[-3]}]="${_json_normal_load_key_value_line[-1]}"
                fi
            fi
        fi
    done

    return ${JSON_COMMON_ERR_DEFINE[ok]}
}

return 0

