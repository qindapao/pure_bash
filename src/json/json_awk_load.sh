. ./meta/meta.sh
((DEFENSE_VARIABLES[json_awk_load]++)) && return 0

. ./json/json_common.sh || return 1
. ./json/json_overlay.sh || return 1
. ./json/json_pack.sh || return 1
. ./json/json_balance_load.sh || return 1
. ./json/json_normal_load.sh || return 1
. ./awk/awk_json.sh || return 1
. ./array/array_qsort.sh || return 1

# _json_load_key_values =
#     0 = '001' $'[ag\n \t"e]' '' '30'
#     1 = '002' '[habbit]' '0' '' 'xxoo'
#     2 = '002' '[habbit]' '1' '' 'ccccccccccccccc'
#     3 = '002' '[habbit]' '2' '' 'kkyy'
#     4 = '001' '[n:am,[]{}e]' '' 'John'
#     5 = '001' '[other]' '' 'declare -A _json_set_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev1=KCk='
#     6 = '002' '[otheragain]' '0' '' 'declare -a _json_set_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev1=KCk='

# :TODO: 这个函数并不支持嵌套转义的情况,比如下面这个字符串无法正确处理
# 是因为JSON.awk本身不支持导致的
# "ag\\n \\t\\\"e\\n"
# 但是python3的json模块是可以正确处理的
json_awk_load ()
{
    meta_var_clear "$1"
    local -n _json_awk_load_json_ref=$1
    local _json_awk_load_json_in_file=$2
    local _json_awk_load_json_out_file="${2%.*}_out.txt"
    # :TODO: json_awk_load的效率完全可以按照python的版本来优化
    # 并且更简单支持子json提取
    # 因为可以直接处理排序获取后的数组即可
    local  _json_awk_load_json_algorithm=${3:-'balance'}
    local -a _json_awk_load_json_sub_keys=("${@:4}")
    local _json_awk_load_filter_head_str=''
    local -i _json_awk_load_filter_num=0
    local -a _json_awk_load_json_array=()
    local _json_awk_load_item
    local _json_awk_load_json_key _json_awk_load_json_key_tmp
    local -a _json_awk_load_json_key_array=()
    local -a _json_awk_load_key_values=()
    local -a _json_awk_load_key_value_line=()
    local _json_awk_load_json_value
    local _json_awk_load_sort_num

    ((${#_json_awk_load_json_sub_keys[@]})) && {
        _json_awk_load_filter_head_str="${_json_awk_load_json_sub_keys[*]@Q}"
        _json_awk_load_filter_num=${#_json_awk_load_json_sub_keys[@]}
    }

    awk_json_files "$_json_awk_load_json_out_file" "$_json_awk_load_json_in_file"
    mapfile -t _json_awk_load_json_array < "$_json_awk_load_json_out_file"

    for _json_awk_load_item in "${_json_awk_load_json_array[@]}" ; do
        if [[ "$_json_awk_load_item" =~ ^\[(([0-9]+,|\"([^\"]|\\\")*\",)*([0-9]+|\"([^\"]|\\\")*\"))\]$'\t'(.*)$ ]] ; then
            _json_awk_load_json_value="${BASH_REMATCH[-1]}"
            awk_json_value_deal _json_awk_load_json_value
            if [[ "$_json_awk_load_json_value" == '[]' ]] ; then
                ((JSON_COMMON_SERIALIZATION_ALGORITHM==JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin])) && {
                    _json_awk_load_json_value="declare -a ${JSON_COMMON_MAGIC_STR}1=()" ; } || {
                    _json_awk_load_json_value="declare -a ${JSON_COMMON_MAGIC_STR}1=${JSON_COMMON_NULL_ARRAY_BASE64}" ;}
            elif [[ "$_json_awk_load_json_value" == '{}' ]] ; then
                ((JSON_COMMON_SERIALIZATION_ALGORITHM==JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin])) && {
                    _json_awk_load_json_value="declare -A ${JSON_COMMON_MAGIC_STR}1=()" ; } || {
                    _json_awk_load_json_value="declare -A ${JSON_COMMON_MAGIC_STR}1=${JSON_COMMON_NULL_ARRAY_BASE64}" ; }
            fi

            _json_awk_load_json_key="${BASH_REMATCH[1]}"
            _json_awk_load_json_key_array=()
            while [[ "$_json_awk_load_json_key" =~ ^([0-9]+,|\"([^\"]|\\\")*\",)(.+)$ ]] ||
                  [[ "$_json_awk_load_json_key" =~ ^([0-9]+|\"([^\"]|\\\")*\")$  ]] ; do
                _json_awk_load_json_key="${BASH_REMATCH[3]}"
                _json_awk_load_json_key_tmp="${BASH_REMATCH[1]}"

                if [[ ',' == "${_json_awk_load_json_key_tmp: -1:1}" ]] ; then
                    # 去掉逗号
                    _json_awk_load_json_key_tmp="${_json_awk_load_json_key_tmp:0:-1}"
                fi

                if [[ "$_json_awk_load_json_key_tmp" == \"*\" ]] ; then
                    # 字典键
                    awk_json_value_deal _json_awk_load_json_key_tmp
                    _json_awk_load_json_key_array+=("[${_json_awk_load_json_key_tmp}]")
                else
                    # 数组索引
                    _json_awk_load_json_key_array+=("$_json_awk_load_json_key_tmp")
                fi
            done

            if [[ -z "$_json_awk_load_filter_head_str" ]] ||
               [[ "${_json_awk_load_json_key_array[*]@Q}" == "${_json_awk_load_filter_head_str}"* ]] ; then

                # 这里首先要去掉需要过滤的键
                _json_awk_load_json_key_array=("${_json_awk_load_json_key_array[@]:_json_awk_load_filter_num}")
                # 如果过滤后变成了空数组,那么证明获取的是一个字符串
                ((${#_json_awk_load_json_key_array[@]})) || {
                    if [[ "${_json_awk_load_json_ref@a}" != *[aA]* ]] ; then
                        _json_awk_load_json_ref="$_json_awk_load_json_value"
                        return ${JSON_COMMON_ERR_DEFINE[ok]}
                    else
                        return ${JSON_COMMON_ERR_DEFINE[get_str_but_declare_not_str_outside]}
                    fi
                }
                # 去掉顶级键
                ((_json_awk_load_filter_num)) || unset -v _json_awk_load_json_key_array[0]

                printf -v _json_awk_load_sort_num "%03d" ${#_json_awk_load_json_key_array[@]}
                _json_awk_load_key_value_line=("$_json_awk_load_sort_num" "${_json_awk_load_json_key_array[@]}" "" "$_json_awk_load_json_value")
                _json_awk_load_key_values+=("${_json_awk_load_key_value_line[*]@Q}")
            fi
            
            # # 设置数据结构的值(都按照字符串设置),默认情况下不要第一个顶级键
            # json_overlay _json_awk_load_json_ref _json_awk_load_json_value "${_json_awk_load_json_key_array[@]:1}"
        fi
    done

    # normal or balance
    json_${_json_awk_load_json_algorithm}_load _json_awk_load_key_values _json_awk_load_json_ref
}

return 0

