# 字符串操作集合(模拟perl5的行为)
# 注意:命令行参数大小限制,数组参数不能过大
# 为了保证引用变量不会重名,所有带引用变量的函数中的局部变量都带函数名字,不带引用变量的函数不受影响
# 如果不需要改变原数组,可以使用下面的方式获取数组内容
# array::merge() {
#     [[ $# -ne 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
#     declare -a arr1=("${!1}")
#     declare -a arr2=("${!2}")
#     declare out=("${arr1[@]}" "${arr2[@]}")
#     printf "%s\n" "${out[@]}"
# }
#
# 有一种临时保存变量的好方法，可以利用declare -p 把需要保存的变量打印到一个临时文件中
# 当需要还原变量的时候，直接source ./tmp_file 就可以在当前环境下加载这些变量

# :TODO: 根据业务需求来实现封装,尽量使纯bash实现

# :TODO: https://github.com/vlisivka/bash-modules/blob/master/bash-modules/src/bash-modules/string.sh
# 这里有一些有用的函数，空了可以整理下

. ./meta.sh
((DEFENSE_VARIABLES[str]++)) && return

# 判断两个字符串相等($2保留为高阶数组中的索引)
str_is_equa () { [[ "$3" == "$1" ]] && return 0 || return 1 ; }

# 判断两个字符串不相等($2保留为高阶数组中的索引)
str_is_not_equa () { [[ "$3" != "$1" ]] && return 0 || return 1 ; }

# 判断一个字符串是否只包含空白字符或者是空字符串
str_is_black_or_empty ()
{
    : "${1#"${1%%[![:space:]]*}"}"
    local deal_str="${_%"${_##*[![:space:]]}"}"
    
    [[ -z "$deal_str" ]] && return 0 || return 1
}


# :TODO: 正则匹配?

# join_str=$(str_join '--' "${array[@]}")
str_join ()
{
    local connector="${1}"
    shift
    local join_str
    join_str=$(printf "%s${connector}" "${@}")
    printf "%s" "${join_str%"$connector"*}"
}

# 字符串转换成数组
str_to_array ()
{
    local _str_to_array_in_str="${1}"
    local -n _str_to_array_out_arr="${2}"
    local delimiter="${3}"
    # 不要使用<<<防止多一个回车符号
    IFS="$delimiter" read -d '' -r -a _str_to_array_out_arr < <(printf "%s" "$_str_to_array_in_str")
}

# 字符串拆分函数,只是对awk的封装,功能多,支持连续分隔符和global
# 由于要开新进程,效率一般
# :TODO: 如果想支持从文件中读取,可以把最后一个参数设计成文件名(最后一个参数并且索引是奇数)
# $ echo "1:xx;yy:12;kk:" | str_split ':' 2 ';' 2
# yy
str_split ()
{
    local input_str
    read -d '' input_str
    local output="$input_str"

    while (($#)) ; do
        local delimiter="${1}"
        local field_number="${2}"
        
        output=$(awk -F "$delimiter" "{print \$$field_number}" < <(printf "%s" "$output"))
        (($#)) && shift
        (($#)) && shift
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

# 判断一个字符串是否是另外一个子字符串
# 1: 需要判断的字符串
# 2: 打桩的参数(高阶函数调用中传入的数组索引)
# 3: 判断是否包含的字符串
# 4: 是否忽略大小写
#       1: 忽略
#       0: 不忽略(默认)
str_contains ()
{
    local long_str="${1}"
    # 这个是一个索引,一般用于map函数中
    local arr_index="${2}"
    local short_str="${3}"
    local is_ignore_case="${4:-0}"
    
    ((is_ignore_case)) && {
        long_str="${long_str,,}"
        short_str="${short_str,,}"
    }

    [[ "$long_str" == *"$short_str"* ]] && return 0 || return 1
}


# 获取目录字符串中的当前目录名
# 用于带文件名的字符串
str_dirname ()
{
    local in_str="${1%/*}"
    printf "%s" "${in_str##*/}"
}

# 获取目录字符串中的完整路径(不带最后的斜杠)
# 用于带文件名的字符串
str_abs_path ()
{
    printf "%s" "${1%/*}"
}

# 从文件路径字符串中解析文件名(不带后缀)
str_basename ()
{
    local out_str="${1##*/}"
    printf "%s" "${out_str%%.*}"
}

# 1: 输入字符串
str_tr_cr_to_space ()
{
    local out_str=''
    out_str="${1//$'\r'/}"
    printf "%s" "${out_str//$'\n'/ }"
}

# 去掉行首和行尾空白字符
# Usage: trim_s "   example   string    "
str_trim ()
{
    : "${1#"${1%%[![:space:]]*}"}"
    printf "%s" "${_%"${_##*[![:space:]]}"}"
}

# 去掉行首空白字符
str_ltrim ()
{
    printf "%s" "${1#"${1%%[![:space:]]*}"}"
}

# 去掉行尾空白字符
str_rtrim ()
{
    printf "%s" "${1%"${1##*[![:space:]]}"}"
}

# 去掉行首行尾所有空格，中间的所有空白保留一个空格
# Usage: trim_all "   example   string    "
str_trim_all ()
{
    local deal_str="${1}"
    declare -a str_arr
    read -d "" -ra str_arr < <(printf "%s" "$deal_str")
    deal_str="${str_arr[*]}"
    printf "%s" "$deal_str"
}

# 去掉前导0(如果单纯只有一个0需要保留)
str_ltrim_zeros ()
{
    local out_str=$(printf "%s" "${1#"${1%%[!0]*}"}" )

    if [[ -z "$out_str" ]] ; then
        printf "%s" "${1}"
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
    local in_str="${1}"
    local index="${2}"
    local prefix="${3}"
    local is_ignore_case="${4}"   
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
    local in_str="${1}"
    local index="${2}"
    local suffix="${3}"
    local is_ignore_case="${4}"
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
    local in_str="${1}"
    
    str_is_num "$in_str" || return

    in_str=$(str_trim_zeros "$in_str")
    printf "0x%x" "$in_str" 
}

# 字符串拆分函数,下面是纯bash实现
# 效率极高
# str_split_pure ' ' 1 "**" 2 ":" 2 ";" 3 < (printf "%s" "   *dge**ge:g;;e;ge:gege*x   dge")
# e
# todo:
#     1. Support reverse interception -1 -2 ... ...
#     2. 如果想支持从文件中读取,可以把最后一个参数设计成文件名(最后一个参数并且索引是奇数)
#
str_split_pure ()
{
    local tmp_str old_str
    declare -i index cnt i_index
    local input_str
    local -a input_arr
    read -d '' input_str
    mapfile -t input_arr < <(printf "%s" "$input_str")

    for tmp_str in "${input_arr[@]}" ; do
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
                read -d "" -ra tmp_arr < <(printf "%s" "$tmp_str")
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

# 可以在函数中使用local修改全局IFS的值，退出函数后，值被还原，只在函数内生效
# 可以避免对全局IFS的变更
# test_1 ()
# {
# 	local IFS=':'
# 	read -r xx yy zz <<< "1:2:3"
# 	echo $xx
# 	echo $yy
# 	echo $zz
# }
# 
# test_1
# 
# read -r xx yy zz <<< "1 2 3"
# echo $xx
# echo $yy
# echo $zz


