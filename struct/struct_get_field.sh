. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_get_field]++)) && return 0

# struct_get_field 'struct_name' 'field_name' '4' '0'
# 获取结构体中某个层级每个字段的值(最终的结果可能是字符串也可能是数组或者关联数组,取决于层级所在数据类型)
# 第一级要么是一个数组要么是一个关联数组
# 1: 顶级数据结构引用
# 2: 获取到的字段保存数据结构引用
# @: 需要获取的字段(不用指定数据类型,只需要指定索引)
#
# 返回值:
#   bit0: 异常1: 索引是否有空值
#   bit1: 异常2: 索引在原数据中是否存在
#   bit2: 异常3: 获取到的数据结构是关联数组,但是外部没有声明
#   bit3: 异常4: 获取到的是字符串,但是外部错误声明为数组或者关联数组
struct_get_field ()
{
    local -n _struct_get_field_struct_ref="${1}"
    local -n _struct_get_field_out_var_name="${2}"
    local _struct_get_field_tmp_var=''
    shift 2
    local _struct_get_field_param=''
    local _struct_get_field_flags=''
    local -i _struct_get_field_ret_code=0

    if [[ -z "${1}" ]] ; then
        # 索引为空值,遇到就返回
        ((_struct_get_field_ret_code|=1))
        return $_struct_get_field_ret_code
    fi
    
    [[ ! -v '_struct_get_field_struct_ref["${1}"]' ]] && ((_struct_get_field_ret_code|=2))

    local _struct_get_field_data_lev_ref_last=${_struct_get_field_struct_ref["${1}"]}

    local -i is_not_first_in=0
    for _struct_get_field_param in "${@:1}" "${1}" ; do
        unset _struct_get_field_tmp_var

        if [[ "$_struct_get_field_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ _struct_set_field_data_lev[0-9]+=(.*) ]] ; then
            _struct_get_field_flags="${BASH_REMATCH[2]}"
            declare ${BASH_REMATCH[2]} _struct_get_field_tmp_var
            eval _struct_get_field_tmp_var="${BASH_REMATCH[3]}"
        else
            _struct_get_field_flags=''
            # 如果不匹配就是普通变量
            local _struct_get_field_tmp_var="${_struct_get_field_data_lev_ref_last}"
            break
        fi

        if ((is_not_first_in++)) ; then
            if [[ -z "$_struct_get_field_param" ]] ; then
                # 索引为空值,遇到就返回
                ((_struct_get_field_ret_code|=1))
                return $_struct_get_field_ret_code
            fi

            [[ ! -v '_struct_get_field_tmp_var["${_struct_get_field_param}"]' ]] && ((_struct_get_field_ret_code|=2))
            _struct_get_field_data_lev_ref_last="${_struct_get_field_tmp_var["$_struct_get_field_param"]}"
        fi
    done
    
    # 复制当前获取到的变量到外部引用变量中(目前这是最好的方式,因为函数中的变量是动态改变类型的)
    # 并且不能在函数内部改变外部变量的属性,所以如果需要获取关联数组或者别的属性
    # 需要在函数外部指定${_struct_get_field_out_var_name}引用的变量的属性
    if [[ "$_struct_get_field_flags" == *[aA]* ]] ; then
        local _struct_get_field_iter_index
        _struct_get_field_out_var_name=()

        # 如果获取到的数据结构是关联数组但是外部没有声明,那么报错
        if [[ "$_struct_get_field_flags" == *A* ]] && [[ "${_struct_get_field_out_var_name@a}" != *A* ]] ; then
            ((_struct_get_field_ret_code|=4))
        fi

        for _struct_get_field_iter_index in "${!_struct_get_field_tmp_var[@]}" ; do
            _struct_get_field_out_var_name["$_struct_get_field_iter_index"]="${_struct_get_field_tmp_var["$_struct_get_field_iter_index"]}"
        done
    else
        # 获取获取到的是字符串,但是外部声明为数组,报错
        if [[ "${_struct_get_field_out_var_name}" == *[aA]* ]] ; then
            ((_struct_get_field_ret_code|=8))
        fi

        _struct_get_field_out_var_name="$_struct_get_field_tmp_var"
    fi

    return $_struct_get_field_ret_code
}

return 0

