. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_get_field]++)) && return 0

. ./array/array_sort.sh || return 1

# struct_get_field 'field_name' 'struct_name' '4' '0'
# 下面可以用于获取索引或者判断字段是否存在
# struct_get_field 'struct_name' '' '4' '0'
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
struct_get_field ()
{
    local -i _struct_get_filed_is_index=1
    if [[ -n "${1}" ]] ; then
        _struct_get_filed_is_index=0
        local -n _struct_get_field_out_var_name=$1
    fi
    local -n _struct_get_field_struct_ref=$2
    local _struct_get_field_tmp_var=''
    shift 2
    local _struct_get_field_param=''
    local _struct_get_field_flags=''
    local -i _struct_get_field_ret_code=0

    [[ -z "${1}" ]] && return 1
    if [[ "${_struct_get_field_struct_ref@a}" != *A* ]] && ! [[ "${1}" =~ ^[1-9][0-9]*$|^0$ ]] ; then
        return 2
    fi

    [[ ! -v '_struct_get_field_struct_ref[${1}]' ]] && return 4

    local _struct_get_field_data_lev_ref_last="${_struct_get_field_struct_ref["${1}"]}"

    local -i is_not_first_in=0
    for _struct_get_field_param in "${@:1}" ; do
        unset _struct_get_field_tmp_var

        if [[ "$_struct_get_field_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ _struct_set_field_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev[0-9]+=(.*) ]] ; then
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
            
            if [[ "$_struct_get_field_flags" != *A* ]] && ! [[ "${_struct_get_field_param}" =~ ^[1-9][0-9]*$|^0$ ]] ; then
                ((_struct_get_field_ret_code|=2))
                return $_struct_get_field_ret_code
            fi
            [[ ! -v '_struct_get_field_tmp_var["${_struct_get_field_param}"]' ]] && {
                ((_struct_get_field_ret_code|=4))
                return $_struct_get_field_ret_code
            }
            _struct_get_field_data_lev_ref_last="${_struct_get_field_tmp_var["$_struct_get_field_param"]}"
        fi
    done
 
    unset _struct_get_field_tmp_var
    if [[ "$_struct_get_field_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ _struct_set_field_chen_xu_yuan_yao_mo_hao_zhi_ji_de_dao_data_lev[0-9]+=(.*) ]] ; then
        _struct_get_field_flags="${BASH_REMATCH[2]}"
        declare ${BASH_REMATCH[2]} _struct_get_field_tmp_var
        eval _struct_get_field_tmp_var="${BASH_REMATCH[3]}"
    else
        _struct_get_field_flags=''
        # 如果不匹配就是普通变量
        local _struct_get_field_tmp_var="${_struct_get_field_data_lev_ref_last}"
    fi

    ((_struct_get_filed_is_index)) && {
        # 打包安全字符串返回索引,如果是最后一级或者没有找到索引,返回打印空字符串
        if [[ "$_struct_get_field_flags" == *[aA]* ]] ; then
            local -a _struct_get_field_indexs=("${!_struct_get_field_tmp_var[@]}")
            case "$_struct_get_field_flags" in
            *a*)    array_sort _struct_get_field_indexs '-gt' ;;
            *A*)    array_sort _struct_get_field_indexs '>' ;;
            esac
            local _struct_get_field_iter_index=''
            for _struct_get_field_iter_index in "${_struct_get_field_indexs[@]}" ; do
                printf "%q\n" "$_struct_get_field_iter_index"
            done
            return 0
        else
            # :TODO: 这里是需要返回Q字符串的空''还是什么都不返回?
            # 如果返回Q字符串的空,那么外部会发生迭代
            # 如果什么都不返回,外部不会发生迭代
            return 1
        fi
    }

    # 复制当前获取到的变量到外部引用变量中(目前这是最好的方式,因为函数中的变量是动态改变类型的)
    # 并且不能在函数内部改变外部变量的属性,所以如果需要获取关联数组或者别的属性
    # 需要在函数外部指定${_struct_get_field_out_var_name}引用的变量的属性
    if [[ "$_struct_get_field_flags" == *[aA]* ]] ; then
        local _struct_get_field_iter_index
        _struct_get_field_out_var_name=()

        # 如果获取到的数据结构是关联数组但是外部没有声明,那么报错
        if [[ "$_struct_get_field_flags" == *A* ]] && [[ "${_struct_get_field_out_var_name@a}" != *A* ]] ; then
            ((_struct_get_field_ret_code|=8))
        else
            for _struct_get_field_iter_index in "${!_struct_get_field_tmp_var[@]}" ; do
                _struct_get_field_out_var_name["$_struct_get_field_iter_index"]="${_struct_get_field_tmp_var["$_struct_get_field_iter_index"]}"
            done
        fi
    else
        # 获取获取到的是字符串,但是外部声明为数组,报错
        if [[ "${_struct_get_field_out_var_name@a}" == *[aA]* ]] ; then
            ((_struct_get_field_ret_code|=16))
        else
            _struct_get_field_out_var_name="$_struct_get_field_tmp_var"
        fi
    fi

    return $_struct_get_field_ret_code
}

alias struct_get_field_index='struct_get_field ""'

return 0

