. ./meta/meta.sh
((DEFENSE_VARIABLES[json_balance_load]++)) && return 0

. ./json/json_common.sh || return 1
. ./json/json_pack.sh || return 1
. ./array/array_qsort.sh || return 1
. ./str/str_ltrim_zeros.sh || return 1

json_balance_load ()
{
    local -n _json_balance_load_key_values=$1
    local -n _json_balance_load_json_out_ref=$2

    ((${#_json_balance_load_key_values[@]})) || return ${JSON_COMMON_ERR_DEFINE[ok]}

    array_qsort _json_balance_load_key_values '<'
    _json_balance_load_key_values+=("'000'")

    # ldebug_bp "show vars" _json_balance_load_key_values

    local -a _json_balance_load_tmp_common_keys=()
    local -a _json_balance_load_current_common_keys=()
    local -a _json_balance_load_tmp_arr_iv=()
    local -A _json_balance_load_tmp_dict_kv=()
    local _json_balance_load_cur_lev _json_balance_load_cur_index _json_balance_load_iter
    local -a _json_balance_load_key_value_line=()
    local -a _json_balance_load_key_value_rebuild=()
    local _json_balance_load_cur_max_lev=''
    local _json_balance_load_cur_max_lev2=''
    local _json_balance_load_first_index=''
    local _json_balance_load_cur_type=''
    local _json_balance_load_keys_num
    local _json_balance_load_pack_str=''

    while true ; do
        # 先清空缓存
        _json_balance_load_tmp_common_keys=()
        _json_balance_load_tmp_arr_iv=()
        _json_balance_load_tmp_dict_kv=()

        # 0号索引永远不会被删除
        eval _json_balance_load_key_value_line=(${_json_balance_load_key_values[0]})
        _json_balance_load_cur_max_lev=${_json_balance_load_key_value_line[0]} ; str_ltrim_zeros _json_balance_load_cur_max_lev
        ((_json_balance_load_cur_max_lev<=1)) && break

        for _json_balance_load_cur_index in "${!_json_balance_load_key_values[@]}" ; do
            eval _json_balance_load_key_value_line=(${_json_balance_load_key_values[_json_balance_load_cur_index]})
            _json_balance_load_cur_lev=${_json_balance_load_key_value_line[0]} ; str_ltrim_zeros _json_balance_load_cur_lev
            _json_balance_load_keys_num=${#_json_balance_load_key_value_line[@]}

            
            # ldebug_bp "show vars" _json_balance_load_key_value_line _json_balance_load_keys_num _json_balance_load_cur_lev

            # 1. common_keys中没有元素
            #   写入common_keys,根据当前数据类型写入到临时数组或者字典中,并且更新_json_balance_load_cur_type _json_balance_load_first_index
            # 2. common_keys中有元素
            #   (1). 当前键相等    => 写缓存数据
            #   (2). 当前键不相等  => 先改变前面的index中的内容,删除被合并的index,降低一级lev写数据,覆盖common_keys和缓存的数据,并且更新_json_balance_load_cur_type和_json_balance_load_first_index 
            
            if ((${#_json_balance_load_tmp_common_keys[@]})) ; then
                _json_balance_load_current_common_keys=("${_json_balance_load_key_value_line[@]:1:_json_balance_load_keys_num-4}")
                if [[ "${_json_balance_load_current_common_keys[*]@Q}" == "${_json_balance_load_tmp_common_keys[*]@Q}" ]] ; then
                    if [[ "$_json_balance_load_cur_type" == 'A' ]] ; then
                        _json_balance_load_tmp_dict_kv[${_json_balance_load_key_value_line[-3]:1:-1}]=${_json_balance_load_key_value_line[-1]}
                    else
                        _json_balance_load_tmp_arr_iv[${_json_balance_load_key_value_line[-3]}]=${_json_balance_load_key_value_line[-1]}
                    fi

                    # ldebug_bp "show vars" _json_balance_load_current_common_keys _json_balance_load_cur_type _json_balance_load_tmp_dict_kv \
                    #     _json_balance_load_tmp_arr_iv
                else
                    if [[ "$_json_balance_load_cur_type" == 'A' ]] ; then
                        json_pack 0 _json_balance_load_tmp_dict_kv _json_balance_load_pack_str
                    else
                        json_pack 0 _json_balance_load_tmp_arr_iv _json_balance_load_pack_str
                    fi

                    # ldebug_bp "show vars" _json_balance_load_pack_str

                    printf -v _json_balance_load_cur_max_lev2 "%03d" $((_json_balance_load_cur_max_lev-1))
                    _json_balance_load_key_value_rebuild=("${_json_balance_load_cur_max_lev2}" "${_json_balance_load_tmp_common_keys[@]}" "" "$_json_balance_load_pack_str")
                    _json_balance_load_key_values[$_json_balance_load_first_index]=${_json_balance_load_key_value_rebuild[*]@Q}
                    if ((_json_balance_load_cur_index-_json_balance_load_first_index>1)) ; then
                        eval -- "unset -v _json_balance_load_key_values[{$((_json_balance_load_first_index+1))..$((_json_balance_load_cur_index-1))}]"
                    fi

                    # ldebug_bp "show vars" _json_balance_load_cur_max_lev2 _json_balance_load_key_values

                    _json_balance_load_tmp_dict_kv=() _json_balance_load_tmp_arr_iv=()

                    # common_keys 和 缓存重新生成
                    _json_balance_load_tmp_common_keys=("${_json_balance_load_current_common_keys[@]}")
                    _json_balance_load_first_index=${_json_balance_load_cur_index}
                    [[ "${_json_balance_load_key_value_line}" != '000' ]] && {
                        if [[ "${_json_balance_load_key_value_line[-3]: -1}" == ']' ]] ; then
                            _json_balance_load_cur_type=A
                            _json_balance_load_tmp_dict_kv[${_json_balance_load_key_value_line[-3]:1:-1}]=${_json_balance_load_key_value_line[-1]}
                        else
                            _json_balance_load_cur_type=a
                            _json_balance_load_tmp_arr_iv[${_json_balance_load_key_value_line[-3]}]=${_json_balance_load_key_value_line[-1]}
                        fi
                    }

                    # ldebug_bp "show vars" _json_balance_load_tmp_common_keys _json_balance_load_first_index _json_balance_load_cur_type \
                    #     _json_balance_load_tmp_dict_kv _json_balance_load_tmp_arr_iv
                fi
            else
                _json_balance_load_tmp_common_keys=("${_json_balance_load_key_value_line[@]:1:_json_balance_load_keys_num-4}")
                _json_balance_load_first_index=${_json_balance_load_cur_index}
                if [[ "${_json_balance_load_key_value_line[-3]: -1}" == ']' ]] ; then
                    _json_balance_load_cur_type=A
                    _json_balance_load_tmp_dict_kv[${_json_balance_load_key_value_line[-3]:1:-1}]=${_json_balance_load_key_value_line[-1]}
                else
                    _json_balance_load_cur_type=a
                    _json_balance_load_tmp_arr_iv[${_json_balance_load_key_value_line[-3]}]=${_json_balance_load_key_value_line[-1]}
                fi

                # ldebug_bp "show vars" _json_balance_load_tmp_common_keys _json_balance_load_first_index _json_balance_load_cur_type \
                #     _json_balance_load_tmp_dict_kv _json_balance_load_tmp_arr_iv
            fi

            # 如果当前行lev已经不对跳出来即可
            ((_json_balance_load_cur_lev!=_json_balance_load_cur_max_lev)) && {
                # ldebug_bp "show vars" _json_balance_load_cur_lev _json_balance_load_cur_max_lev
                break
            }
        done

        # 对数组重新排序
        array_qsort _json_balance_load_key_values '<'
        # ldebug_bp "show vars" _json_balance_load_key_values
    done

    # local end=$(date +%s.%N)
    
    # 做最后的集成(:TODO: 当前发现这样还是节省不了多少时间)
    if ((${#_json_balance_load_key_values[@]})) ; then
        # 去掉最后一个元素
        eval _json_balance_load_key_value_line=(${_json_balance_load_key_values[0]})
        if [[ "${_json_balance_load_key_value_line[1]: -1}" == ']' ]] ; then
            _json_balance_load_cur_type=A
        else
            _json_balance_load_cur_type=a
        fi

        for _json_balance_load_iter in "${_json_balance_load_key_values[@]}" ; do
            [[ "$_json_balance_load_iter" == "'000'" ]] && break
            eval _json_balance_load_key_value_line=(${_json_balance_load_iter})
            if [[ "$_json_balance_load_cur_type" == 'A' ]] ; then
                _json_balance_load_json_out_ref[${_json_balance_load_key_value_line[1]:1:-1}]=${_json_balance_load_key_value_line[-1]}
            else
                _json_balance_load_json_out_ref[${_json_balance_load_key_value_line[1]}]=${_json_balance_load_key_value_line[-1]}
            fi
        done
    fi

    return ${JSON_COMMON_ERR_DEFINE[ok]}
}

return 0

