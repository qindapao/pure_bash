. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_eval_p]++)) && return 0

. ./str/str_index_of.sh || return 1
. ./array/array_del_elements_dense.sh || return 1

# 处理eval函数的参数,提高eval代码的可读性
# 之所以这么麻烦就是因为bash的正则无法支持非贪婪搜索和负向断言导致
atom_eval_p ()
{
    set -- '
    shift
    local local_var_key_S1= local_var_value_S1=
    local script_copy=$S1 ; S1=
    shift
    local -A params_S1=()
    local -a indexs_keys_S1=()
    local word_S1 min_index_S1 min_key_S1 ret

    while (($#)) ; do
        params_S1[$1]=$2 ; indexs_keys_S1+=("$1")
        local_var_key_S1+="$1" ; local_var_value_S1+="$2"
        shift 2
    done
    params_S1[$local_var_key_S1]=$local_var_value_S1
    indexs_keys_S1=("$local_var_key_S1" "${indexs_keys_S1[@]}")

    while((${#indexs_keys_S1[@]})) || [[ -n "$script_copy" ]] ; do
        min_index_S1=-1 ; min_key_S1=
        for word_S1 in "${indexs_keys_S1[@]}" ; do
            if ! str_index_of "$script_copy" "$word_S1" ; then
                array_del_elements_dense indexs_keys_S1 "$word_S1"
                continue
            fi

            if (((min_index_S1==-1)||(ret<min_index_S1))) ; then
                min_index_S1=$ret
                min_key_S1=$word_S1
            fi
        done
        ((${#indexs_keys_S1[@]})) || break

        # 开始处理字符串
        S1+="${script_copy:0:min_index_S1}"
        S1+="${params_S1[$min_key_S1]}"
        script_copy=${script_copy:min_index_S1+${#min_key_S1}}
    done
    S1+="$script_copy"
    ' "${@}"

    eval -- "${1//S1/$2}"
}

return 0

