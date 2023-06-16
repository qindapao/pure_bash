#!/usr/bin/env bash

# pure bash lib
# Do not use external tools unless you have to because of the bash version
# In fact, printf is also time-consuming. If you need extreme performance, 
# you can use the method of passing by reference to output the result.
# The code is temporarily not implemented and can be rewritten

trim_s ()
{
    # Usage: trim_s "   example   string    "
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s\n' "$_"
}

trim_all () {
    # Usage: trim_all "   example   string    "
    local deal_str="$1"
    declare -a str_arr
    read -d "" -ra str_arr <<<"$deal_str"
    deal_str="${str_arr[*]}"
    printf "%s\n" "$deal_str"
    
}

# awk_str ' ' 1 "**" 2 ":" 2 ";" 3 <<<"   *dge**ge:g;;e;ge:gege*x   dge"
# e
# todo:
#     1. Support reverse interception -1 -2 ... ...
awk_str ()
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
