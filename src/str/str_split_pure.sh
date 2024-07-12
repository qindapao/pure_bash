. ./meta/meta.sh
((DEFENSE_VARIABLES[str_split_pure]++)) && return 0

# :TODO: 是否需要整改用于高阶函数中?
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

return 0

