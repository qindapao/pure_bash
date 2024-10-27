. ./meta/meta.sh
((DEFENSE_VARIABLES[str_split]++)) && return 0

. ./str/str_trim_all.sh || return 1
. ./str/str_to_array.sh || return 1
. ./atom/atom_unlocal.sh || return 1

# 使用block的方式在高阶函数中使用此函数
# 字符串拆分函数,下面是纯bash实现
# 效率极高
# str_split' ' 1 "**" 2 ":" 2 ";" 3 < (printf "%s" "   *dge**ge:g;;e;ge:gege*x   dge")
# e
# :TODO:
#     1. Support reverse interception -1 -2 ... ...
#
str_split ()
{
    ret_str_split=''
    local tmp_str old_str
    declare -i index cnt i_index
    local input_str
    local -a input_arr=()
    # 默认是标准输出
    local out_method=0

    while (($#)) ; do
        case $1 in
        -i)
        # 从标准输入获取数据
        IFS= read -r -d '' input_str || true ; shift
        set -- '' '' "${@}"
        break
        ;;
        # 从字符串获取数据
        -s)
        input_str=$2
        break
        ;;
        # 一定把这个设置成第一个参数
        -v)
        # 输出类型1是字符串
        out_method=1 ; shift
        ;;
        -a)
        # 输出到数组的变量中(数组名和索引占据前两个变量)
        input_str=$4
        out_method=2
        set -- "${2}" "${3}" "${@:5}"
        local ret_str_split
        break
        ;;
        esac
    done

    str_to_array input_arr "$input_str" $'\n'
    for tmp_str in "${input_arr[@]}" ; do
        for((index=3;index<=$#;index+=2)) ; do
            ((cnt=index+1))
            [[ -z "$tmp_str" ]] && break
            # If it is an empty separator, use string interception directly
            [[ -z "${!index}" ]] && tmp_str=${tmp_str:${!cnt}-1:1} && continue
            # If it is a space delimiter (the default space delimiter is an empty delimiter, 
            # which does not distinguish between TAB), 
            # first trim the string to remove all redundant spaces
            [[ "${!index}" == [[:space:]] ]] && str_trim_all 'tmp_str'

            for((i_index=0;i_index<${!cnt}-1;i_index++)) ; do
                old_str="$tmp_str"
                tmp_str=${tmp_str#*"${!index}"}
                [ -z "$tmp_str" ] && break 2
                # If tmp_str is the same as old_str, it proves that the interception is invalid, and it is empty directly
                [[ "$tmp_str" == "$old_str" ]] && tmp_str='' && break 2
            done
            tmp_str=${tmp_str%%"${!index}"*}
        done
        if ((out_method)) ; then
            ret_str_split+="${tmp_str}"$'\n'
        else
            printf "%s\n" "$tmp_str"
        fi
    done
    [[ -n "$ret_str_split" ]] && ret_str_split=${ret_str_split%?}
    ((out_method==2)) && {
        # 更新外部数组变量
        local "$1" && atom_unlocal "$1"
        eval -- $1[\$2]='${ret_str_split}'
    }
}

# 这里的双引号最好留着,表明是一个参数
alias str_split_i='str_split "-i"'
alias str_split_s='str_split "-s"'
alias str_split_sv='str_split "-v" "-s"'
alias str_split_a='str_split "-a"'

return 0

