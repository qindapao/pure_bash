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

# trim_all The first version, with lower performance
# Usage: trim_all_1 "   example   string    "
trim_all_1 ()
{
    local deal_str="$1" new_str
    deal_str=$(trim_s "$deal_str")
    declare -i i mark=0
    for((i=0;i<${#deal_str};i++)) ; do
        [[ "${deal_str:i:1}" == [[:space:]] ]]  && {
            [[ "1" = "$mark" ]] && continue
            mark=1 ; new_str+=' ' ; continue
        }
        mark=0 ; new_str+="${deal_str:i:1}"
    done
    printf "%s\n" "$new_str"
}

# trim_all The second version has higher performance, but triggers shell_check
# shellcheck disable=SC2086,SC2048
trim_all () {
    # Usage: trim_all "   example   string    "
    set -f
    set -- $*
    printf '%s\n' "$*"
    set +f
}

# awk_str "   *dge**ge:g;;e;ge:gege*x   dge" ' ' 1 "**" 2 ":" 2 ";" 3
# todo:
#     1. Support reverse interception -1 -2 ... ...
awk_str ()
{
    local tmp_str="$1" old_str
    declare -i index cnt i_index
    for((index=2;index<=$#;index+=2)) ; do
        ((cnt=index+1))
        [[ -z "$tmp_str" ]] && break
        # If it is an empty separator, use string interception directly
        [[ -z "${!index}" ]] && tmp_str=${tmp_str:${!cnt}-1:1} && continue
        # If it is a space delimiter (the default space delimiter is an empty delimiter, 
        # which does not distinguish between TAB), 
        # first trim the string to remove all redundant spaces
        [[ "${!index}" == [[:space:]] ]] && {
            set -f
            local tmp_arr=($tmp_str)
            tmp_str="${tmp_arr[*]}"
            set +f
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
}

