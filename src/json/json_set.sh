. ./meta/meta.sh
((DEFENSE_VARIABLES[json_set]++)) && return 0

# . ./log/log_dbg.sh || return 1
. ./base64/base64_decode.sh || return 1
. ./json/json_common.sh || return 1
. ./json/json_pack.sh || return 1
. ./regex/regex_common.sh || return 1

# json_set 'json_name' '4' '0' '[key1]' i "value"
# json_set 'json_name' '4' '0' '[key1]' - "value"
# - 短杠表示字符串

# :TODO: 后续结构体中的set -x打印也应该要屏蔽
# :TODO: bash4.4以后才支持@A的语法,当前只为bash4.4以后支持
# :TODO: 保存后的结构体中的数组中的元素不允许有额外属性,比如i,所有不支持类似整形数组这种
#        Storage:~ # declare -p a
#        declare -ai a=([0]="1" [1]="2")
#        Storage:~ # 
#        默认所有保存的关联数组和索引数组都是字符串形式,没有额外的i(整形) u(大小) l(小写) 等等属性

# 结构体复合变量创建
# 第一级要么是一个数组要么是一个关联数组
# 返回值:
#   bit0: 索引是否是空值(索引不允许是空值)
#   bit1: 设置为非A数据结构,但是原始保存的是A,那么异常
#   bit2: 传入的数字索引并不是10进制数字
#   bit3: 不是关联数组但是想访问非数字键
json_set ()
{
    local -n _json_set_json_ref=$1
    shift

    # 不用限制层数(但是不要太深,目前验证20层执行时间是10层的200倍,这里的时间消耗可能是解释器内部都引号或者转义字符的处理,是根据层级指数递增的)
    # 嵌套深的情况下,会保存很多额外的反斜杠,内存消耗变大,字符串变长,然后正则处理的时间可能就大幅度增加了,这也可能是时间超长原因
    # :TODO: 后续能通过不用正则匹配的方法来实现吗?(目前发现时间消耗差不多,可读性反而不好)
    # 可以考虑使用数组来储存每级的属性和值(数组配对),反序列化后就可以直接拿取属性和值,不用每次都正则,应该是能大幅提高性能
    # :TODO: 验证下内存消耗情况?应该是不大的
    # 这个变量为什么这么长?为了防止和用户自定义的字符串名字冲突,可以把这个变量名理解为一个密码
    # eval local ${JSON_COMMON_MAGIC_STR}{1..20}=''
    # 记录每层需要更新的索引(0 1层不处理先占位)
    local -a _json_set_index_lev=('' '') _json_set_index_type=('' '')
    local _json_set_{index,set_type,set_index,top_level_str}
    _json_set_top_level_str="${@:$#:1}"

    local _json_set_set_index_first="${1#[}" ; _json_set_set_index_first="${_json_set_set_index_first%]}"

    [[ -z "$_json_set_set_index_first" ]] && return ${JSON_COMMON_ERR_DEFINE[set_null_key]}
    # 不是关联数组,但是要访问非数字键
    if [[ "${_json_set_json_ref@a}" != *A* ]] && ! [[ "${_json_set_set_index_first}" =~ $REGEX_COMMON_UINT_DECIMAL ]] ; then
        return ${JSON_COMMON_ERR_DEFINE[set_key_but_not_dict]}
    fi

    if [ -v '_json_set_json_ref[$_json_set_set_index_first]' ] ; then
        local _json_set_data_lev_ref_last=${_json_set_json_ref["$_json_set_set_index_first"]}
    else
        local _json_set_data_lev_ref_last=''
    fi

    for((_json_set_index=2;_json_set_index<$#-1;_json_set_index++)) ; do
        _json_set_set_type='a' ; _json_set_set_index="${!_json_set_index}"

        if [[ "[" == "${_json_set_set_index:0:1}" ]] ; then
            [[ "${_json_set_set_index: -1}" != ']' ]] && return ${JSON_COMMON_ERR_DEFINE[set_key_right_side_wrong]}
            _json_set_set_type='A' ; _json_set_set_index="${_json_set_set_index:1:-1}"
        else
            # 判断是否是10进制数字
            [[ "$_json_set_set_index" =~ ^[1-9][0-9]*$|^0$ ]] || return ${JSON_COMMON_ERR_DEFINE[set_key_index_not_decimal]}
        fi

        # 检查索引是否是空值,如果是直接异常退出
        [[ -z "$_json_set_set_index" ]] && return ${JSON_COMMON_ERR_DEFINE[set_null_key]}

        # 不限制层数,在这里初始化
        local ${JSON_COMMON_MAGIC_STR}${_json_set_index}=''
        local -n _json_set_data_lev_ref=${JSON_COMMON_MAGIC_STR}${_json_set_index}

        # 转换上一个数据类型 
        # :TODO: 注意,其它相关函数这里需要统一
        # :TODO: 这里使用正则弄一个很大的字符串可能效率不高,可以可虑用简单的字符串操作拆分为3部分
        #   part1: ${_json_set_data_lev_ref_last%% *} 
        #   part2: temp=${_json_set_data_lev_ref_last#* } ; temp=${temp%% *}
        #   part3: ${_json_set_data_lev_ref_last#*=}
        #   但是使用正则的可读性更好
        # 不要嵌套太深,字符数量千万级的时候,这里需要4秒
        if [[ "$_json_set_data_lev_ref_last" =~ ^(declare)\ ([^\ ]+)\ ${JSON_COMMON_MAGIC_STR}[0-9]+=(.*) ]] ; then
            # 这里要进行键校验(设置为非A数据结构,但是原始保存的是A,那么异常)
            # 关联数组转换成索引数组不允许,但是索引数组转换成关联数组可以
            if [[ 'A' != "$_json_set_set_type" ]] && [[ "${BASH_REMATCH[2]}" == *A* ]] ; then
                return ${JSON_COMMON_ERR_DEFINE[set_convert_dict_to_array]}
            fi

            declare -${_json_set_set_type} ${JSON_COMMON_MAGIC_STR}${_json_set_index}
            ((JSON_COMMON_SERIALIZATION_ALGORITHM==JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin])) && {
                eval _json_set_data_lev_ref="${BASH_REMATCH[3]}" ; } || {
                    base64_decode _json_set_data_lev_ref "${BASH_REMATCH[3]}"
                    eval _json_set_data_lev_ref="$_json_set_data_lev_ref" ; }

            # 只有设置了对应的属性才能访问键,不然如果是字符串访问,会严重异常
            _json_set_data_lev_ref_last="${_json_set_data_lev_ref["$_json_set_set_index"]}"
        fi

        _json_set_index_lev+=("$_json_set_set_index")
        _json_set_index_type+=("$_json_set_set_type")
    done

    # 获取需要设置的值字符串
    _json_set_set_type="${@:$#-1:1}" ; _json_set_top_level_str="${@:$#:1}"

    # 设置值
    declare -${_json_set_set_type:--} _json_set_tmp_var="$_json_set_top_level_str"

    # 开始从尾部开始往上回溯(顶层不考虑)
    for ((_json_set_index=${#_json_set_index_lev[@]}-1;_json_set_index>1;_json_set_index--)) ; do
        # 取出当前层数据结构
        local -n _json_set_data_lev_ref=${JSON_COMMON_MAGIC_STR}${_json_set_index}

        # 对相应的_json_set_index赋值
        declare -${_json_set_index_type[_json_set_index]} ${JSON_COMMON_MAGIC_STR}${_json_set_index}
        
        # 先打印原始的值
        _json_set_data_lev_ref["${_json_set_index_lev[_json_set_index]}"]="$_json_set_tmp_var"

        # 当前数据结果完整的序列化保存到_json_set_tmp_var
        # 这里要先取消变量的属性
        unset -v _json_set_tmp_var ; local _json_set_tmp_var=''
        # 嵌套太深,字符数量千万级的时候,这里需要0.6秒(这个语法bash4.4以及以后引入)
        # declare -p 的字符串在bash5.2返回引用字符串,在以前的版本是原始字符串
        # 但是这没有关系
        # declare -- valid_chars=$'abcd\n '
        # declare -- 'valid_chars=abcd
        #  '
        # 上面两种情况变量是相等的，特别注意 declare -- valid_chars="$'abcd\n '"
        # 如果在已经是引用字符串外面再套一层引号再赋值，就不是原字符串自己了。而是引用字符串本身，切记!
        # 就像下面这样,所以解包的时候才需要eval展开
        json_pack_o '_json_set_data_lev_ref' '_json_set_tmp_var' "${JSON_COMMON_MAGIC_STR}${_json_set_index}"
    done
    
    # 最终把_json_set_tmp_var更新到最顶层
    _json_set_json_ref["$_json_set_set_index_first"]="$_json_set_tmp_var"
    return ${JSON_COMMON_ERR_DEFINE[ok]}
}

return 0

