. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_set_field]++)) && return 0

# . ./log/log_dbg.sh || return 1

# struct_set_field 'struct_name' '4' '0' '[key1]' i "value"
# struct_set_field 'struct_name' '4' '0' '[key1]' - "value"
# - 短杠表示字符串

# :TODO: 后续结构体中的set -x打印也应该要屏蔽
# :TODO: bash4.4以后才支持@A的语法,当前只为bash4.4以后支持

# 结构体复合变量创建
# 第一级要么是一个数组要么是一个关联数组
# 返回值:
#   bit0: 索引是否是空值(索引不允许是空值)
struct_set_field ()
{
    local -n _struct_set_field_struct_ref="${1}"
    shift

    # 记录每层的数据(最大支持20层)
    # :TODO: 这里是否不要限制?
    eval local _struct_set_field_data_lev{1..20}=''
    # 记录每层需要更新的索引(0层不处理先占位)
    local -a _struct_set_field_index_lev=('') _struct_set_filed_index_type=('')
    local _struct_set_field_index _struct_set_field_set_type _struct_set_field_set_index _struct_set_field_top_level_str
   
    local _struct_set_field_set_index_first="${1#[}" ; _struct_set_field_set_index_first="${_struct_set_field_set_index_first%]}"
    local _struct_set_field_data_lev_ref_last=${_struct_set_field_struct_ref["$_struct_set_field_set_index_first"]}

    for((_struct_set_field_index=2;_struct_set_field_index<$#-1;_struct_set_field_index++)) ; do
        _struct_set_field_set_type='a' ; _struct_set_field_set_index="${!_struct_set_field_index}"
        [[ "[" == "${!_struct_set_field_index:0:1}" ]] && {
            _struct_set_field_set_type='A' ; _struct_set_field_set_index="${!_struct_set_field_index:1:-1}"
        }

        # 检查索引是否是空值,如果是直接异常退出
        [[ -z "$_struct_set_field_set_index" ]] && return 1

        local -n _struct_set_field_data_lev_ref=_struct_set_field_data_lev${_struct_set_field_index}

        # 转换上一个数据类型 
        # :TODO: 注意,其它相关函数这里需要统一
        if [[ "$_struct_set_field_data_lev_ref_last" =~ ^(declare\ [^\ ]+\ )_struct_set_field_data_lev[0-9]+=(.*) ]] ; then
            declare -${_struct_set_field_set_type} _struct_set_field_data_lev${_struct_set_field_index}
            eval _struct_set_field_data_lev_ref="${BASH_REMATCH[2]}"
        fi

        _struct_set_field_data_lev_ref_last="${_struct_set_field_data_lev_ref["$_struct_set_field_set_index"]}"

        _struct_set_field_index_lev+=("$_struct_set_field_set_index")
        _struct_set_filed_index_type+=("$_struct_set_field_set_type")
    done

    _struct_set_field_index_lev=('' "${_struct_set_field_index_lev[@]}") ; _struct_set_filed_index_type=('' "${_struct_set_filed_index_type[@]}")

    # 获取需要设置的值字符串
    _struct_set_field_set_type="${@:$#-1:1}" ; _struct_set_field_top_level_str="${@:$#:1}"

    # 设置值
    declare -${_struct_set_field_set_type:--} _struct_set_field_tmp_var="$_struct_set_field_top_level_str"

    # 开始从尾部开始往上回溯(顶层不考虑)
    for ((_struct_set_field_index=${#_struct_set_field_index_lev[@]}-1;_struct_set_field_index>1;_struct_set_field_index--)) ; do
        # 取出当前层数据结构
        local -n _struct_set_field_data_lev_ref=_struct_set_field_data_lev${_struct_set_field_index}

        # 对相应的_struct_set_field_index赋值
        declare -${_struct_set_filed_index_type[_struct_set_field_index]} _struct_set_field_data_lev${_struct_set_field_index}
        
        # 先打印原始的值
        _struct_set_field_data_lev_ref["${_struct_set_field_index_lev[_struct_set_field_index]}"]="$_struct_set_field_tmp_var"

        # 当前数据结果完整的序列化保存到_struct_set_field_tmp_var
        # 这里要先取消变量的属性
        unset _struct_set_field_tmp_var ; local _struct_set_field_tmp_var=''
        _struct_set_field_tmp_var="${_struct_set_field_data_lev_ref[@]@A}"
    done
    
    # 最终把_struct_set_field_tmp_var更新到最顶层
    _struct_set_field_struct_ref["$_struct_set_field_set_index_first"]="$_struct_set_field_tmp_var"
    return 0
}

return 0

