. ./meta/meta.sh
((DEFENSE_VARIABLES[json_attr_get]++)) && return 0

. ./base64/base64_decode.sh || return 1
. ./json/json_common.sh || return 1

# json_attr_get 'field_attr' 'json_name' '4' '0'
# 获取结构体中某个层级某个字段的属性
# 第一级要么是一个数组要么是一个关联数组
# 1: 获取到的属性保存的变量名称
# 2: 顶级数据结构引用
# @: 需要获取的字段(不用指定数据类型,只需要指定索引)对应的数据结构的类型
#   a: 数组
#   A: 关联数组
#   s: 字符串
#
# 返回值:
#   json_get的返回值
json_attr_get ()
{
    local -n _json_attr_get_out_var_name=$1
    local -n _json_attr_get_json_ref=$2
    local _json_attr_get_tmp_var=''
    shift 2
    local _json_attr_get_param=''
    local _json_attr_get_flags=''

    [[ -z "${1}" ]] && return ${JSON_COMMON_ERR_DEFINE[get_null_key]}
    if [[ "${_json_attr_get_json_ref@a}" != *A* ]] && ! [[ "${1}" =~ ^[1-9][0-9]*$|^0$ ]] ; then
        return ${JSON_COMMON_ERR_DEFINE[get_key_but_not_dict]}
    fi

    [[ ! -v '_json_attr_get_json_ref[${1}]' ]] && return ${JSON_COMMON_ERR_DEFINE[get_key_not_found]}

    local _json_attr_get_data_lev_ref_last="${_json_attr_get_json_ref["${1}"]}"

    local -i is_not_first_in=0
    for _json_attr_get_param in "${@:1}" ; do
        unset -v _json_attr_get_tmp_var

        if [[ "$_json_attr_get_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ ${JSON_COMMON_MAGIC_STR}[0-9]+=(.*) ]] ; then
            _json_attr_get_flags="${BASH_REMATCH[2]}"
            declare ${BASH_REMATCH[2]} _json_attr_get_tmp_var
            ((JSON_COMMON_SERIALIZATION_ALGORITHM==JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin])) && {
                eval _json_attr_get_tmp_var="${BASH_REMATCH[3]}" ; } || {
                    base64_decode _json_attr_get_tmp_var "${BASH_REMATCH[3]}"
                    eval _json_attr_get_tmp_var="$_json_attr_get_tmp_var" ; }
        else
            _json_attr_get_flags=''
            # 如果不匹配就是普通变量
            local _json_attr_get_tmp_var="${_json_attr_get_data_lev_ref_last}"
            break
        fi

        if ((is_not_first_in++)) ; then
            if [[ -z "$_json_attr_get_param" ]] ; then
                # 索引为空值,遇到就返回
                return ${JSON_COMMON_ERR_DEFINE[get_null_key]}
            fi
            
            if [[ "$_json_attr_get_flags" != *A* ]] && ! [[ "${_json_attr_get_param}" =~ ^[1-9][0-9]*$|^0$ ]] ; then
                return ${JSON_COMMON_ERR_DEFINE[get_key_but_not_dict]}
            fi
            [[ ! -v '_json_attr_get_tmp_var["${_json_attr_get_param}"]' ]] && {
                return ${JSON_COMMON_ERR_DEFINE[get_key_not_found]}
            }
            _json_attr_get_data_lev_ref_last="${_json_attr_get_tmp_var["$_json_attr_get_param"]}"
        fi
    done
 
    if [[ "$_json_attr_get_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ ${JSON_COMMON_MAGIC_STR}[0-9]+=(.*) ]] ; then
        _json_attr_get_flags="${BASH_REMATCH[2]}"
    else
        _json_attr_get_flags=''
    fi

    case "$_json_attr_get_flags" in
    *a*)    _json_attr_get_out_var_name=a ;; 
    *A*)    _json_attr_get_out_var_name=A ;;
    *)      _json_attr_get_out_var_name=s ;;
    esac
    return ${JSON_COMMON_ERR_DEFINE[ok]}
}

return 0

