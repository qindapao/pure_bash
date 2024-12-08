. ./meta/meta.sh
((DEFENSE_VARIABLES[array_qsort]++)) && return 0

# :TODO: 可以升级支持用awk进行浮点数的排序
_array_qsort_use_sort_cmd ()
{
    local -n _aqusc_arr_ref="$1"
    local -a _aqusc_arr_copy=()
    local _aqusc_sort_rule="${2}"

    case "$_aqusc_sort_rule" in
         -[gl]t) _aqusc_arr_copy=("${_aqusc_arr_ref[@]}") ;;&
            -gt) local -a _aqusc_sort_cmd_param=(-n) ;;
            -lt) local -a _aqusc_sort_cmd_param=(-rn) ;;
        '>'|'<') _aqusc_arr_copy=("${_aqusc_arr_ref[@]@Q}") ;;&
            '>') local -a _aqusc_sort_cmd_param=() ;;
            '<') local -a _aqusc_sort_cmd_param=(-r) ;;
    esac

    local _aqusc_joined_str= _aqusc_sorted_str=
    printf -v _aqusc_joined_str "%s\n" "${_aqusc_arr_copy[@]}"
    _aqusc_sorted_str=$(sort "${_aqusc_sort_cmd_param[@]}" <<<"$_aqusc_joined_str")
    local IFS=$'\n'
    case "$_aqusc_sort_rule" in
        -[gl]t)
        _aqusc_arr_copy=(${_aqusc_sorted_str}) ;;
        '>'|'<')
        eval _aqusc_arr_copy=(${_aqusc_sorted_str}) ;;
    esac

    local -i _aqusc_item 
    local -i _aqusc_copy_i=0
    for _aqusc_item in "${!_aqusc_arr_ref[@]}" ; do
        _aqusc_arr_ref[_aqusc_item]=${_aqusc_arr_copy[_aqusc_copy_i++]}
    done
}

array_qsort () 
{
    (($# < 1)) && return 1
    local -n _array_qsort_arr_ref=$1
    local -i _array_qsort_arr_len=${#_array_qsort_arr_ref[@]}
    ((_array_qsort_arr_len)) || return 2

    # 默认是字典升序
    local _array_qsort_sort_rule=${2:-">"}

    # 判断数组的长度,如果超过100就使用外部工具排序
    # 目前看起来外部工具排序速度完胜
    ((_array_qsort_arr_len>100)) && {
        _array_qsort_use_sort_cmd "$1" "$_array_qsort_sort_rule"
        return $?
    }

    # 为了支持稀疏数组,可以先拷贝一份
    local -a _array_qsort_arr_copy=()
    local -i _array_qsort_left=0
    local -i _array_qsort_right=$((_array_qsort_arr_len-1))
    local _array_qsort_sort_opo_rule=
    case "$_array_qsort_sort_rule" in
    '>'|'<') _array_qsort_arr_copy=("${_array_qsort_arr_ref[@]@Q}") ;;&
        '>')    _array_qsort_sort_opo_rule='<' ;;
        '<')    _array_qsort_sort_opo_rule='>' ;;
    -[gl]t) _array_qsort_arr_copy=("${_array_qsort_arr_ref[@]}") ;;&
        '-lt')    _array_qsort_sort_opo_rule='-gt' ;;
        '-gt')    _array_qsort_sort_opo_rule='-lt' ;;
    esac

    local -a _array_qsort_stack=()
    local -i _array_qsort_top=-1 _array_qsort_i _array_qsort_j _array_qsort_mid
    local _array_qsort_partition_item _array_qsort_temp

    # Push initial values of left and right to _array_qsort_stack
    _array_qsort_stack[++_array_qsort_top]=$_array_qsort_left
    _array_qsort_stack[++_array_qsort_top]=$_array_qsort_right

    while ((_array_qsort_top >= 0)); do
        # Pop right and left
        _array_qsort_right=_array_qsort_stack[_array_qsort_top--]
        _array_qsort_left=_array_qsort_stack[_array_qsort_top--]

        _array_qsort_i=$_array_qsort_left
        _array_qsort_j=$_array_qsort_right
        ((_array_qsort_mid = (_array_qsort_left + _array_qsort_right) / 2))
        _array_qsort_partition_item="${_array_qsort_arr_copy[$_array_qsort_mid]}"

        while ((_array_qsort_i <= _array_qsort_j)); do
            # 这里使用eval命令也会影响效率的,实际验证发现700个数组元素排序,用了eval耗时0.164s,不用耗时0.071s
            # 如果对效率敏感这里可以优化,用case？但是也不绝对,为了代码的简洁这里还是用eval吧
            while eval [[ '"${_array_qsort_arr_copy[_array_qsort_i]}"' "${_array_qsort_sort_opo_rule}" '"${_array_qsort_partition_item}"' ]] ; do
                ((_array_qsort_i++))
            done

            # 下面的代码可能能提高1倍效率,但是表现力不如eval,暂时不使用
            # while : ; do
            #     case "$_array_qsort_sort_rule" in
            #     '>') [[ "${_array_qsort_arr_copy[_array_qsort_i]}" > "$_array_qsort_partition_item" ]] && break ;;
            #     '<') [[ "${_array_qsort_arr_copy[_array_qsort_i]}" < "$_array_qsort_partition_item" ]] && break ;;
            #     '-lt') [[ "${_array_qsort_arr_copy[_array_qsort_i]}" -le "$_array_qsort_partition_item" ]] && break ;;
            #     '-gt') [[ "${_array_qsort_arr_copy[_array_qsort_i]}" -ge "$_array_qsort_partition_item" ]] && break ;;
            #     esac
            #     ((_array_qsort_i++))
            # done

            while eval [[ '"${_array_qsort_arr_copy[_array_qsort_j]}"' "${_array_qsort_sort_rule}" '"${_array_qsort_partition_item}"' ]] ; do
                ((_array_qsort_j--))
            done
            
            # while : ; do
            #     case "$_array_qsort_sort_rule" in
            #     '>') [[ "${_array_qsort_arr_copy[_array_qsort_j]}" < "$_array_qsort_partition_item" ]] && break ;;
            #     '<') [[ "${_array_qsort_arr_copy[_array_qsort_j]}" > "$_array_qsort_partition_item" ]] && break ;;
            #     '-lt') [[ "${_array_qsort_arr_copy[_array_qsort_j]}" -ge "$_array_qsort_partition_item" ]] && break ;;
            #     '-gt') [[ "${_array_qsort_arr_copy[_array_qsort_j]}" -le "$_array_qsort_partition_item" ]] && break ;;
            #     esac
            #     ((_array_qsort_j--))
            # done

            if ((_array_qsort_i <= _array_qsort_j)); then
                _array_qsort_temp="${_array_qsort_arr_copy[$_array_qsort_i]}"
                _array_qsort_arr_copy[$_array_qsort_i]="${_array_qsort_arr_copy[$_array_qsort_j]}"
                _array_qsort_arr_copy[$_array_qsort_j]="$_array_qsort_temp"
                ((_array_qsort_i++))
                ((_array_qsort_j--))
            fi
        done

        # Push left and right subarrays to _array_qsort_stack
        if ((_array_qsort_left < _array_qsort_j)); then
            _array_qsort_stack[++_array_qsort_top]=$_array_qsort_left
            _array_qsort_stack[++_array_qsort_top]=$_array_qsort_j
        fi
        if ((_array_qsort_i < _array_qsort_right)); then
            _array_qsort_stack[++_array_qsort_top]=$_array_qsort_i
            _array_qsort_stack[++_array_qsort_top]=$_array_qsort_right
        fi
    done
    
    # 把拷贝数组重新拷贝回原数组(支持稀疏特性)
    local -i _array_qsort_item 
    local -i _array_qsort_copy_i=0
    case "$_array_qsort_sort_rule" in
    -[gl]t)
        for _array_qsort_item in "${!_array_qsort_arr_ref[@]}" ; do
            _array_qsort_arr_ref[_array_qsort_item]=${_array_qsort_arr_copy[_array_qsort_copy_i++]}
        done
        ;;
    '>'|'<')
        for _array_qsort_item in "${!_array_qsort_arr_ref[@]}" ; do
            # 后面的双引号是一定不能省略的
            eval _array_qsort_arr_ref[_array_qsort_item]="${_array_qsort_arr_copy[_array_qsort_copy_i++]}"
        done
        ;;
    esac

    return 0
}

return 0

