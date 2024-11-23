. ./meta/meta.sh
((DEFENSE_VARIABLES[array_dump]++)) && return 0

. ./array/array_qsort.sh || return 1
. ./regex/regex_common.sh || return 1

# 树状打印一个数组或者关联数组或者普通字符串
# 关联数组键排序
# 要打印出来也很简单,但是一般不建议在数组中强制属性,容易造成程序崩溃
array_dump ()
{
    local -n _array_dump_ref_arr=$1
    local -n _array_dump_out_str=$2
    local _array_dump_declare_str=$(declare -p "$1" 2>/dev/null)
    local _array_dump_prt_str="$1"
    local -a _array_dump_keys=()
    local _array_dump_key _array_dump_key_mark='='
    local _array_dump_prt_tmp_str
    
    while true ; do
        if [[ "$_array_dump_declare_str" =~ $REGEX_COMMON_DECLARE_REF ]] ; then
            _array_dump_declare_str="$(declare -p "${BASH_REMATCH[1]}" 2>/dev/null)"
            _array_dump_prt_str+="->${BASH_REMATCH[1]}"
        else
            if [[ -n "$_array_dump_declare_str" ]] ; then
                if [[ "${_array_dump_ref_arr@a}" == *[aA]* ]] ; then

                    # 加上数组的属性
                    if [[ "$_array_dump_declare_str" =~ $REGEX_COMMON_DECLARE_CONTAINER ]] ; then
                        _array_dump_prt_str+="(${BASH_REMATCH[1]})"
                    fi

                    case "${_array_dump_ref_arr@a}" in 
                        *a*)    _array_dump_prt_str+=' :=' ;;
                        *A*)    _array_dump_prt_str+=' :=>';;
                    esac

                    _array_dump_prt_str+=$'\n'

                    _array_dump_declare_str="$_array_dump_prt_str"
                    _array_dump_keys=("${!_array_dump_ref_arr[@]}")
                    if ((${#_array_dump_keys[@]})) ; then
                        if [[ "${_array_dump_ref_arr@a}" == *A* ]] ; then
                            array_qsort _array_dump_keys '>' 
                            _array_dump_key_mark='=>'
                        fi

                        for _array_dump_key in "${_array_dump_keys[@]}"; do
                            printf -v _array_dump_prt_tmp_str "    %s %s %s" "$_array_dump_key" \
                                                                             "$_array_dump_key_mark" \
                                                                             "${_array_dump_ref_arr[$_array_dump_key]}"
                            _array_dump_prt_tmp_str+=$'\n'
                            _array_dump_declare_str+="$_array_dump_prt_tmp_str"
                        done
                    fi
                else
                    # 相等是没有引用变量的情况
                    [[ "$_array_dump_prt_str" == "$1" ]] && _array_dump_prt_str='' || _array_dump_prt_str+=' '
                    _array_dump_declare_str="${_array_dump_prt_str}${_array_dump_declare_str:8}"
                    _array_dump_declare_str+=$'\n'
                fi
            else
                _array_dump_declare_str="-- ${_array_dump_prt_str}=null"
                _array_dump_declare_str+=$'\n'
            fi
            break
        fi
    done
    
    _array_dump_out_str="$_array_dump_declare_str"
}

return 0

