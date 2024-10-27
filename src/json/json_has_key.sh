. ./meta/meta.sh
((DEFENSE_VARIABLES[json_has_key]++)) && return 0

. ./base64/base64_decode.sh || return 1
. ./json/json_common.sh || return 1
. ./regex/regex_common.sh || return 1

# json_has_key 'json_name' '4' '0'
# 获取结构体中某个层级某个字段的属性
# 第一级要么是一个数组要么是一个关联数组
# 1: 顶级数据结构引用
# @: 需要获取的字段(不用指定数据类型,只需要指定索引)对应的数据结构的类型
#   a: 数组
#   A: 关联数组
#   s: 字符串
#
# 返回值:
#   0: 有键
#   json_get 的异常返回值
json_has_key ()
{
    local -n _json_has_key_json_ref=$1
    local _json_has_key_tmp_var=''
    shift
    local _json_has_key_param=''
    local _json_has_key_flags=''

    [[ -z "${1}" ]] && return ${JSON_COMMON_ERR_DEFINE[get_null_key]}
    if [[ "${_json_has_key_json_ref@a}" != *A* ]] && ! [[ "${1}" =~ $REGEX_COMMON_UINT_DECIMAL ]] ; then
        return ${JSON_COMMON_ERR_DEFINE[get_key_but_not_dict]}
    fi

    [[ ! -v '_json_has_key_json_ref[${1}]' ]] && return ${JSON_COMMON_ERR_DEFINE[get_key_not_found]}

    local _json_has_key_data_lev_ref_last="${_json_has_key_json_ref["${1}"]}"

    local -i _json_has_key_is_not_first_in=0
    for _json_has_key_param in "${@}" ; do
        unset -v _json_has_key_tmp_var

        if [[ "$_json_has_key_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ ${JSON_COMMON_MAGIC_STR}[0-9]+=(.*) ]] ; then
            _json_has_key_flags="${BASH_REMATCH[2]}"
            declare ${BASH_REMATCH[2]} _json_has_key_tmp_var
            ((JSON_COMMON_SERIALIZATION_ALGORITHM==JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin])) && {
                eval _json_has_key_tmp_var="${BASH_REMATCH[3]}" ; } || {
                    base64_decode _json_has_key_tmp_var "${BASH_REMATCH[3]}"
                    eval _json_has_key_tmp_var="$_json_has_key_tmp_var" ; }
        else
            (($#!=1)) && return ${JSON_COMMON_ERR_DEFINE[get_not_fully_traversed]}
            break
        fi

        if ((_json_has_key_is_not_first_in++)) ; then
            if [[ -z "$_json_has_key_param" ]] ; then
                # 索引为空值,遇到就返回
                return ${JSON_COMMON_ERR_DEFINE[get_null_key]}
            fi
            
            if [[ "$_json_has_key_flags" != *A* ]] && ! [[ "${_json_has_key_param}" =~ $REGEX_COMMON_UINT_DECIMAL ]] ; then
                return ${JSON_COMMON_ERR_DEFINE[get_key_but_not_dict]}
            fi
            [[ ! -v '_json_has_key_tmp_var["${_json_has_key_param}"]' ]] && {
                return ${JSON_COMMON_ERR_DEFINE[get_key_not_found]}
            }
            _json_has_key_data_lev_ref_last="${_json_has_key_tmp_var["$_json_has_key_param"]}"
        fi
    done

    return ${JSON_COMMON_ERR_DEFINE[ok]}
}

return 0

