# 字符串操作集合(模拟perl5的行为)
# 注意:命令行参数大小限制,数组参数不能过大
# 为了保证引用变量不会重名,所有带引用变量的函数中的局部变量都带函数名字,不带引用变量的函数不受影响

# :TODO: 根据业务需求来实现封装,尽量使纯bash实现

((__STR++)) && return

# join_str=$(str_join '--' "${array[@]}")
str_join ()
{
    local connector="$1"
    shift 1
    local join_str
    join_str=$(printf "%s${connector}" "${@}")
    printf "%s" "${join_str%"$connector"*}"
}

# 字符串转换成数组
str_to_array ()
{
    local _str_to_array_in_str="$1"
    local -n _str_to_array_out_arr="$2"
    local delimiter="$3"
    # 不要使用<<<防止多一个回车符号
    IFS="$delimiter" read -d '' -r -a _str_to_array_out_arr < <(printf "%s" "$_str_to_array_in_str")
}

# 字符串拆分函数,只是对awk的封装,功能多,支持连续分隔符和global
# 由于要开新进程,效率一般
# $ echo "1:xx;yy:12;kk:" | str_split ':' 2 ';' 2
# yy
str_split ()
{
    local input_str
    read -d '' input_str
    local output="$input_str"

    while (($#)) ; do
        local delimiter="$1"
        local field_number="$2"
        
        output=$(awk -F "$delimiter" "{print \$$field_number}" < <(printf "%s" "$output"))
        shift 2
    done
    
    printf "%s" "$output"
}

str_is_num ()
{
    if [[ $1 =~ ^0[xX][0-9A-Fa-f]+$ ]] || [[ $1 =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# 获取目录字符串中的当前目录名
str_dirname ()
{
    :
}

# 获取目录字符串中的完整路径
str_abs_path ()
{
    :
}

# 从文件路径字符串中解析文件名(不带后缀)
str_basename ()
{
    local out_str=
    out_str=${1##*/}
    out_str=${out_str%%.*}
    printf "%s" "$out_str"
}

# 1: 输入字符串
str_tr_cr_to_space ()
{
    printf "%s" "${1//$'\n'/ }"
}

# 去掉行首和行尾空白字符
# Usage: trim_s "   example   string    "
str_trim ()
{
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s' "$_"
}

# 去掉行首空白字符
str_ltrim ()
{
    : "${1#"${1%%[![:space:]]*}"}"
    printf '%s' "$_"
}

# 去掉行尾空白字符
str_rtrim ()
{
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s' "$_"
}

# 去掉行首行尾所有空格，中间的所有空白保留一个空格
# Usage: trim_all "   example   string    "
str_trim_all ()
{
    local deal_str="$1"
    declare -a str_arr
    read -d "" -ra str_arr <<<"$deal_str"
    deal_str="${str_arr[*]}"
    printf "%s" "$deal_str"
}

# 去掉前导0(如果单纯只有一个0需要保留)
str_ltrim_zeros ()
{
    local out_str=$(printf "%s" "${1#"${1%%[!0]*}"}" )

    if [[ -z "$out_str" ]] ; then
        printf "%s" "$1"
    else
        printf "%s" "$out_str"

    fi
}

# 字符串以什么开头(满足返回true,否则返回false,大小写敏感)
# 1: 需要检查的字符串
# 2: 如果字符串在一个数组中,那么这个数组的索引(主要是为了高阶函数)
# 3: 需要检查的前缀
# 4: 是否忽略大小写(默认不忽略)
# 5: 字符串开始索引[可选,如果没有就是从0开始]
# 6: 字符串结束索引[可选,如果没有就是在最大结束]
str_startswith() 
{
    local in_str="$1"
    local index="$2"
    local prefix="$3"
    local is_ignore_case="$4"   
    ((is_ignore_case)) && {
        in_str=${in_str,,}
        prefix=${prefix,,}
    }
    local start_pos="${5:-0}"
    local str_len=${#in_str}
    local end_pos="${6:-${str_len}}"

    # 如果开始或结束位置是负数，则从字符串末尾开始计算
    ((start_pos<0)) && ((start_pos+=str_len))
    ((end_pos<0))   && ((end_pos+=str_len))

    # 检查索引范围是否有效
    ((start_pos>=str_len || start_pos<0)) && return 1

    # 调整结束索引，如果超出字符串长度则设置为字符串长度
    ((end_pos>str_len)) && ((end_pos=str_len))

    # 如果结束索引小于开始索引，返回假
    ((end_pos<start_pos)) && return 1

    # 提取子字符串
    local sub_str="${in_str:$start_pos:$end_pos - start_pos}"

    # 检查子字符串是否以前缀开始
    [[ "$sub_str" == "$prefix"* ]] && return 0 || return 1
}

# 字符串以什么结尾(满足返回true,否则返回false,大小写敏感)
# 1: 需要检查的字符串
# 2: 如果字符串在一个数组中,那么这个数组的索引(主要是为了高阶函数)
# 3: 需要检查的后缀
# 4: 是否忽略大小写(默认不忽略)
# 5: 字符串开始索引[可选,如果没有就是从0开始]
# 6: 字符串结束索引[可选,如果没有就是在最大结束]
str_endswith ()
{
    local in_str="$1"
    local index="$2"
    local suffix="$3"
    local is_ignore_case="$4"
    ((is_ignore_case)) && {
        in_str=${in_str,,}
        suffix=${suffix,,}
    }
    local start_pos="${5:-0}"
    local str_len=${#in_str}
    local end_pos="${6:-${str_len}}"

    # 如果开始或结束位置是负数，则从字符串末尾开始计算
    ((start_pos<0)) && ((start_pos+=str_len))
    ((end_pos<0))   && ((end_pos+=str_len))

    # 检查索引范围是否有效
    ((start_pos>=str_len || start_pos < 0)) && return 1

    # 调整结束索引，如果超出字符串长度则设置为字符串长度
    ((end_pos>str_len)) && ((end_pos=str_len))

    # 如果结束索引小于开始索引，返回假
    ((end_pos<start_pos)) && return 1

    # 提取子字符串
    local sub_str="${in_str:$start_pos:$end_pos - start_pos}"

    # 检查子字符串是否以后缀结束
    [[ "$sub_str" == *"$suffix" ]] && return 0 || return 1
}

# 字符串转换成小写
str_lower ()
{
    printf "%s" "${1,,}"
}

# 字符串转换成大写
str_upper ()
{
    printf "%s" "${1^^}"
}

str_to_hex ()
{
    local in_str="$1"
    
    str_is_num "$in_str" || return

    in_str=$(str_trim_zeros "$in_str")
    printf "0x%x" "$in_str" 
}


# 使用方法
# xx=$(set_bit_value "0x34a" 0:1 2:0 3:1 4:1 12:1 13:1)
# 最后得到的值是0x335b
str_set_bit_value ()
{
    local value=$1
    shift
    # write_info的格式为(表示每个bit对应需要写入的值):
    # 0:0 2:1 4:0 5:0 7:1 14:1
    
    local write_bit=() bit_value=()
    local i
    for i in "$@" ; do
        write_bit+=("${i%:*}") ; bit_value+=("${i##*:}")
    done
    
    for((i=0;i<${#write_bit[@]};i++))
    do
        value=$(( (bit_value[i] << write_bit[i]) | (value & (~(0x1 << write_bit[i]))) ))
    done
    printf "0x%02x" "$value"
}

# 字符串拆分函数,下面是纯bash实现
# 效率极高
# str_split_pure ' ' 1 "**" 2 ":" 2 ";" 3 <<<"   *dge**ge:g;;e;ge:gege*x   dge"
# e
# todo:
#     1. Support reverse interception -1 -2 ... ...
str_split_pure ()
{
    local tmp_str old_str
    declare -i index cnt i_index
    while IFS= read -r tmp_str ; do
        for((index=1;index<=$#;index+=2)) ; do
            ((cnt=index+1))
            [[ -z "$tmp_str" ]] && break
            # If it is an empty separator, use string interception directly
            [[ -z "${!index}" ]] && tmp_str=${tmp_str:${!cnt}-1:1} && continue
            # If it is a space delimiter (the default space delimiter is an empty delimiter, 
            # which does not distinguish between TAB), 
            # first trim the string to remove all redundant spaces
            [[ "${!index}" == [[:space:]] ]] && {
                declare -a tmp_arr
                read -d "" -ra tmp_arr <<<"$tmp_str"
                tmp_str="${tmp_arr[*]}"
            }

            for((i_index=0;i_index<${!cnt}-1;i_index++)) ; do
                old_str="$tmp_str"
                tmp_str=${tmp_str#*"${!index}"}
                [ -z "$tmp_str" ] && break 2
                # If tmp_str is the same as old_str, it proves that the interception is invalid, and it is empty directly
                [[ "$tmp_str" == "$old_str" ]] && tmp_str='' && break 2
            done
            tmp_str=${tmp_str%%"${!index}"*}
        done
        printf "%s\n" "$tmp_str"
    done
}


