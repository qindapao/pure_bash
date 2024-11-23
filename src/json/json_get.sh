. ./meta/meta.sh
((DEFENSE_VARIABLES[json_get]++)) && return 0

. ./base64/base64_decode.sh || return 1
. ./json/json_common.sh || return 1
. ./array/array_qsort.sh || return 1
. ./regex/regex_common.sh || return 1
. ./cntr/cntr_copy.sh || return 1

# json_get 'field_name' 'json_name' '4' '0'
# 下面可以用于获取索引或者判断字段是否存在
# json_get 'json_name' '' '4' '0'
# 获取结构体中某个层级每个字段的值(最终的结果可能是字符串也可能是数组或者关联数组,取决于层级所在数据类型)
# 第一级要么是一个数组要么是一个关联数组
# 1: 获取到的字段保存数据结构引用
#   空: 获取索引,并不是获取字段值
#       获取某一级的索引,通过Q字符串返回，每个索引一行
#       外部通过IFS=$'\n'来拿迭代索引,使用的时候解码(使用的使用eval "xx=$xx"的方式解码键)
#       这同样可以用于判断字段是否存在,只需要调用的时候判断返回值,并且屏蔽输出即可
#   有值: 获取具体的字段值
# 2: 顶级数据结构引用
# @: 需要获取的字段(不用指定数据类型,只需要指定索引)
#
# 返回值:
#   bit0: 异常1: 索引是否有空值
#               如果是获取索引的场景: 表示没有获取到索引,同时会打印空字符串
#   bit1: 异常2: 原始键是非关联数组(普通数组),但是想要获取的是字符串键
#   bit2: 异常3: 索引在原数据中是否存在
#   bit4: 异常4: 获取到的数据结构是关联数组,但是外部没有声明
#   bit5: 异常5: 获取到的是字符串,但是外部错误声明为数组或者关联数组
json_get ()
{
    local -i _json_get_filed_is_index=1
    if [[ -n "${1}" ]] ; then
        _json_get_filed_is_index=0
        meta_var_clear "$1"
        local -n _json_get_out_var_name=$1
    fi
    local -n _json_get_json_ref=$2
    local _json_get_tmp_var=''
    shift 2
    local _json_get_param=''
    local _json_get_flags=''
    local -i _json_get_ret_code=0

    [[ -z "${1}" ]] && return ${JSON_COMMON_ERR_DEFINE[get_null_key]}
    if [[ "${_json_get_json_ref@a}" != *A* ]] && ! [[ "${1}" =~ $REGEX_COMMON_UINT_DECIMAL ]] ; then
        return ${JSON_COMMON_ERR_DEFINE[get_key_but_not_dict]}
    fi

    [[ ! -v '_json_get_json_ref[${1}]' ]] && return ${JSON_COMMON_ERR_DEFINE[get_key_not_found]}

    local _json_get_data_lev_ref_last="${_json_get_json_ref["${1}"]}"

    local -i _json_get_is_not_first_in=0
    for _json_get_param in "${@}" ; do
        unset -v _json_get_tmp_var

        if [[ "$_json_get_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ ${JSON_COMMON_MAGIC_STR}[0-9]+=(.*) ]] ; then
            _json_get_flags="${BASH_REMATCH[2]}"
            declare ${BASH_REMATCH[2]} _json_get_tmp_var
            ((JSON_COMMON_SERIALIZATION_ALGORITHM==JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin])) && {
                eval _json_get_tmp_var="${BASH_REMATCH[3]}" ; } || {
                    base64_decode _json_get_tmp_var "${BASH_REMATCH[3]}"
                    eval _json_get_tmp_var="$_json_get_tmp_var" ; }
        else
            (($#!=1)) && return ${JSON_COMMON_ERR_DEFINE[get_not_fully_traversed]}
            _json_get_flags=''
            # 如果不匹配就是普通变量
            local _json_get_tmp_var="${_json_get_data_lev_ref_last}"
            break
        fi

        if ((_json_get_is_not_first_in++)) ; then
            if [[ -z "$_json_get_param" ]] ; then
                # 索引为空值,遇到就返回
                return ${JSON_COMMON_ERR_DEFINE[get_null_key]}
            fi
            
            if [[ "$_json_get_flags" != *A* ]] && ! [[ "${_json_get_param}" =~ $REGEX_COMMON_UINT_DECIMAL ]] ; then
                return ${JSON_COMMON_ERR_DEFINE[get_key_but_not_dict]}
            fi
            [[ ! -v '_json_get_tmp_var["${_json_get_param}"]' ]] && {
                return ${JSON_COMMON_ERR_DEFINE[get_key_not_found]}
            }
            _json_get_data_lev_ref_last="${_json_get_tmp_var["$_json_get_param"]}"
        fi
    done
 
    unset -v _json_get_tmp_var
    if [[ "$_json_get_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ ${JSON_COMMON_MAGIC_STR}[0-9]+=(.*) ]] ; then
        _json_get_flags="${BASH_REMATCH[2]}"
        declare ${BASH_REMATCH[2]} _json_get_tmp_var
        ((JSON_COMMON_SERIALIZATION_ALGORITHM==JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin])) && {
            eval _json_get_tmp_var="${BASH_REMATCH[3]}" ; } || {
                base64_decode _json_get_tmp_var "${BASH_REMATCH[3]}"
                eval _json_get_tmp_var="$_json_get_tmp_var" ; }
    else
        _json_get_flags=''
        # 如果不匹配就是普通变量
        local _json_get_tmp_var="${_json_get_data_lev_ref_last}"
    fi

    ((_json_get_filed_is_index)) && {
        # 打包安全字符串返回索引,如果是最后一级或者没有找到索引,返回打印空字符串
        if [[ "$_json_get_flags" == *[aA]* ]] ; then
            local -a _json_get_indexs=("${!_json_get_tmp_var[@]}")
            case "$_json_get_flags" in
            # 普通数组根本不用排序
            *A*)    array_qsort _json_get_indexs '>' ;;
            esac
            local _json_get_iter_index=''
            for _json_get_iter_index in "${_json_get_indexs[@]}" ; do
                printf "%q\n" "$_json_get_iter_index"
            done
            return ${JSON_COMMON_ERR_DEFINE[ok]}
        else
            # :TODO: 这里是需要返回Q字符串的空''还是什么都不返回?
            # 如果返回Q字符串的空,那么外部会发生迭代
            # 如果什么都不返回,外部不会发生迭代
            return ${JSON_COMMON_ERR_DEFINE[undefined]}
        fi
    }

    # 复制当前获取到的变量到外部引用变量中(目前这是最好的方式,因为函数中的变量是动态改变类型的)
    # 并且不能在函数内部改变外部变量的属性,所以如果需要获取关联数组或者别的属性
    # 需要在函数外部指定${_json_get_out_var_name}引用的变量的属性
    if [[ "$_json_get_flags" == *[aA]* ]] ; then
        local _json_get_iter_index

        # 如果获取到的数据结构是关联数组但是外部没有声明,那么报错
        if [[ "$_json_get_flags" == *A* ]] && [[ "${_json_get_out_var_name@a}" != *A* ]] ; then
            _json_get_ret_code=${JSON_COMMON_ERR_DEFINE[get_dict_but_not_declare_outside]}
        else
            cntr_copy _json_get_out_var_name _json_get_tmp_var
        fi
    else
        # 获取获取到的是字符串,但是外部声明为数组,报错
        if [[ "${_json_get_out_var_name@a}" == *[aA]* ]] ; then
            _json_get_ret_code=${JSON_COMMON_ERR_DEFINE[get_str_but_declare_not_str_outside]}
        else
            _json_get_out_var_name="$_json_get_tmp_var"
        fi
    fi

    return $_json_get_ret_code
}

alias json_get_index='json_get ""'

return 0

