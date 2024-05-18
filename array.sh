# 数组操作集合(模拟perl5的行为)

# 往数组的尾部添加元素(添加的元素可以是数组,不能是稀疏数组)
# 命令行参数有大小限制，不能太大
# 为了防止有引用变量的情况下的变量污染,所有带引用变量的库函数都以_函数名_打头
# 所有 : 的函数都是暂时未实现的

((__ARRAY++)) && return

. ./atom.sh
. ./str.sh

array_push ()
{
    local -n _array_push_ref_arr="$1"
    shift
    _array_push_ref_arr+=("${@}")
}

# 往数组的头部添加元素(添加的元素可以是数组,不能是稀疏数组)
# 命令行参数有大小限制，不能太大
array_unshift ()
{
    local -n _array_unshift_ref_arr="$1"
    shift
    local -a _array_unshift_new_arr=()
    local -i _array_unshift_i
    _array_unshift_new_arr+=("${@}")
    local -i _array_unshift_new_arr_cnt=${#_array_unshift_new_arr[@]}
    for _array_unshift_i in "${!_array_unshift_ref_arr[@]}" ; do
        _array_unshift_new_arr[_array_unshift_i+_array_unshift_new_arr_cnt]="${_array_unshift_ref_arr[_array_unshift_i]}"
    done
    
    _array_unshift_ref_arr=()

    for _array_unshift_i in "${!_array_unshift_new_arr[@]}" ; do
        _array_unshift_ref_arr[_array_unshift_i]="${_array_unshift_new_arr[_array_unshift_i]}"
    done
}

# 删除数组的最后一个元素并且返回
# 使用方法 element=$(array_pop "arr_name")
array_pop ()
{
    local -n _array_pop__ref_arr="$1"
    local _array_pop_ref_pop_element=
    ((${#_array_pop__ref_arr[@]})) || return 
    
    _array_pop_ref_pop_element=${_array_pop__ref_arr[-1]}
    unset _array_pop__ref_arr[-1]
    printf "%s" "$_array_pop_ref_pop_element"
}

# 删除数组的第一个元素并且返回
# 使用方法 element=$(array_shift "arr_name")
array_shift ()
{
    local -n _array_shift_ref_arr="$1"
    local array_shift_shift_element=
    local _array_shift_index_str="${!_array_shift_ref_arr[*]}"
    [[ -z "$_array_shift_index_str" ]] && return
    local _array_shift_first_index=${_array_shift_index_str%%[[:space:]]*}
    
    array_shift_shift_element="${_array_shift_ref_arr[_array_shift_first_index]}"
    unset _array_shift_ref_arr[_array_shift_first_index]
    local -i _array_shift_i
    local -a _array_shift_new_arr=()
    
    for _array_shift_i in "${!_array_shift_ref_arr[@]}" ; do
        _array_shift_new_arr[_array_shift_i-1]="${_array_shift_ref_arr[_array_shift_i]}"
    done
    
    _array_shift_ref_arr=()

    for _array_shift_i in "${!_array_shift_new_arr[@]}" ; do
        _array_shift_ref_arr[_array_shift_i]="${_array_shift_new_arr[_array_shift_i]}"
    done
    printf "%s" "$array_shift_shift_element"
}

# 取数组的第一个元素，但是不删除它(对应 shift)
array_peek ()
{
    :
}

# 取数组的最后一个元素，但是不删除它(对应 pop)
array_tail ()
{
    :
}


# 数组元素查找(支持关联数组和普通数组)
# 1: 需要操作的数组引用
# 2: 输出的数组引用(满足条件的元素放这里,得到的数组不是稀疏数组)
# 3: 一个函数,第一个参数是当前的字符串,其它的参数为函数自带,最后一个参数是当前索引(可选,如果筛选函数需要使用数组索引)
# 返回值
# 真: 有元素捕捉到
# 假: 无元素捕捉到
array_grep ()
{
    local -n _array_grep_ref_arr="$1" _array_grep_ref_out_arr="$2"
    _array_grep_ref_out_arr=()
    local _array_grep_function="$3"
    shift 3
    local -a _array_grep_params=("${@}")
    local _array_grep_i
    
    for _array_grep_i in "${!_array_grep_ref_arr[@]}" ; do
        if "$_array_grep_function" "${_array_grep_ref_arr[$_array_grep_i]}" "$_array_grep_i" "${_array_grep_params[@]}"  ; then
            # 为了支持关联数组普通数组最后可能是一个稀疏数组
            _array_grep_ref_out_arr[$_array_grep_i]="${_array_grep_ref_arr[$_array_grep_i]}"
        fi
    done

    if((${#_array_grep_ref_out_arr[@]})) ; then
        if atom_identify_data_type _array_grep_ref_out_arr 'a' ; then
            _array_grep_ref_out_arr=("${_array_grep_ref_out_arr[@]}")
        fi
        return 0
    else
        return 1
    fi
}

# 使用匿名代码块来进行过滤
array_grep_block ()
{
    local -n _array_grep_block_ref_arr="$1" _array_grep_block_out_arr="$2"
    _array_grep_block_out_arr=()
    local _array_grep_block_exec_block="$3"

    eval "_array_grep_block_tmp_function() { "$_array_grep_block_exec_block" }"
    local _array_grep_block_index

    for _array_grep_block_index in "${!_array_grep_block_ref_arr[@]}" ; do
        if _array_grep_block_tmp_function "${_array_grep_block_ref_arr[$_array_grep_block_index]}" "$_array_grep_block_index" ; then
            _array_grep_block_out_arr[$_array_grep_block_index]="${_array_grep_block_ref_arr[$_array_grep_block_index]}"
        fi
    done

    unset -f _array_grep_block_tmp_function

    if((${#_array_grep_ref_out_arr[@]})) ; then
        if atom_identify_data_type _array_grep_block_out_arr 'a' ; then
            _array_grep_block_out_arr=("${_array_grep_block_out_arr[@]}")
        fi
        return 0
    else
        return 1
    fi
}


# 数组的map函数，对数组中的每个元素执行特定的函数
# 1: 需要操作的数组的名字
# 2: 函数名(提供一个操作函数,这个函数依次作用于每个数组元素并改变它)
#           
# @: 其它参数为这个函数需要的参数(函数的第一个参数默认为当前数组元素)
#       每次执行后的结果作为下次的输入
#       提供的函数范例(当前是不带参数的,还可以带参数)
#       str_basename ()
#       {
#           local in_str="$1"
#           out_str=${in_str##*/}
#           out_str=${out_str%%.*}
#           printf "%s" "$out_str"
#       }
# 最后一个参数可选: 当前迭代数组索引

array_map ()
{
    local -n _array_map_ref_arr="$1"
    local _array_map_function="$2"
    shift 2
    local _array_map_function_params=("${@}")
    local _array_map_index
    for _array_map_index in "${!_array_map_ref_arr[@]}" ; do
        _array_map_ref_arr[$_array_map_index]=$("$_array_map_function" "${_array_map_ref_arr[$_array_map_index]}" "$_array_map_index" "${_array_map_function_params[@]}")
    done
}

# 执行一个匿名函数
# $ array_map_block a "$(cat <<-'EOF'
# local x=$1 ;
# printf "%s" $((x+1)) ;
# EOF  
# )" 
#
# 1: 需要迭代操作的数据引用
# 2: 执行的匿名代码块
array_map_block ()
{
    local -n _array_map_block_ref_arr="$1"
    local _array_map_block_exec_block="$2" 
    
    eval "_array_map_block_tmp_function() { "$_array_map_block_exec_block" }"
    local _array_map_block_index

    for _array_map_block_index in "${!_array_map_block_ref_arr[@]}" ; do
        _array_map_block_ref_arr[$_array_map_block_index]=$(_array_map_block_tmp_function "${_array_map_block_ref_arr[$_array_map_block_index]}" "$_array_map_block_index")
    done

    unset -f _array_map_block_tmp_function
}

# 对映射的每个数组元素进行操作,但是不改变原数组
array_map_readonly ()
{
    local -n array_map_readonly_ref_arr="$1"
    local array_map_readonly_function="$2"
    shift 2
    local array_map_readonly_function_params=("${@}")
    local array_map_readonly_index
    for array_map_readonly_index in "${!array_map_readonly_ref_arr[@]}" ; do
        "$array_map_readonly_function" "${array_map_readonly_ref_arr[$array_map_readonly_index]}" "$array_map_readonly_index" "${array_map_readonly_function_params[@]}"
    done
}

# 执行匿名代码块不改变原始数组
array_map_readonly_block ()
{
    local -n array_map_readonly_block_ref_arr="$1"
    local array_map_readonly_block_exec_block="$2" 
    
    eval "array_map_readonly_block_tmp_function() { "$array_map_readonly_block_exec_block" }"
    local array_map_readonly_block_index

    for array_map_readonly_block_index in "${!array_map_readonly_block_ref_arr[@]}" ; do
        array_map_readonly_block_tmp_function "${array_map_readonly_block_ref_arr[$array_map_readonly_block_index]}" "$array_map_readonly_block_index"
    done

    unset -f array_map_readonly_block_tmp_function
}



# 排序一个数组中的元素(只能用于普通数组),关联数组没有顺序无法排序
# 规则:默认按照字典序排序
# 算法:当前使用冒泡排序算法
# 1: 需要排序数组引用名
array_sort ()
{
    local -n _array_sort_ref_arr="$1"
    declare -a _array_sort_arr_indexs=("${!_array_sort_ref_arr[@]}")
    ((${#_array_sort_arr_indexs[@]})) || return 

    local -a _array_sort_tmp_arr=("${_array_sort_ref_arr[@]}")
    local -i _array_sort_tmp_arr_size=${#_array_sort_tmp_arr[@]}

    local -i _array_sort_i _array_sort_j
    local _array_sort_tmp

    for ((_array_sort_i = 0; _array_sort_i < _array_sort_tmp_arr_size; _array_sort_i++)); do
        for ((_array_sort_j = 0; _array_sort_j < _array_sort_tmp_arr_size-$_array_sort_i-1; _array_sort_j++)); do
            if [[ "${_array_sort_tmp_arr[_array_sort_j]}" > "${_array_sort_tmp_arr[_array_sort_j+1]}" ]]; then
                _array_sort_tmp="${_array_sort_tmp_arr[_array_sort_j]}"
                _array_sort_tmp_arr[_array_sort_j]="${_array_sort_tmp_arr[_array_sort_j+1]}"
                _array_sort_tmp_arr[_array_sort_j+1]="$_array_sort_tmp"
            fi
        done
    done
    
    # 还原原始数组的索引(因为可能是个稀疏数组)
    _array_sort_j=0
    for _array_sort_i in "${_array_sort_arr_indexs[@]}" ; do
        _array_sort_ref_arr[_array_sort_i]="${_array_sort_tmp_arr[_array_sort_j++]}"
    done
}

# 读取文件中的所有行并追加到一个数组中
array_read_file ()
{
    local -n _array_read_file_ref_arr="$1"
    shift
    
    local _array_read_file_path

    for _array_read_file_path in "${@}" ; do
        [[ -s "$_array_read_file_path" ]] && {
            mapfile -t -O "${#_array_read_file_ref_arr[@]}" _array_read_file_ref_arr < "$_array_read_file_path"
        }
    done
}

# 快速排序(后面实现)
array_qsort ()
{
    :
}

# 判断一个数据结构是否是一个数组(不管是否是引用都能正确处理)
# 1: 需要判断的数组的名字
# :TODO: 后续可以加参数支持关联数组判断(看起来意义不大?可以使用别的函数名)
array_is_normal_array ()
{
    atom_identify_data_type "$1" "a" && return 0 || return 1
}

# 去重一个数组中的元素,最后返回一个新的去重后的数组
# 1: 需要去重的数组的引用名
# 2: 去重后保存的数组名(如果这个参数为空表示直接更新原数组)
# 3: 是否保留原始的index(默认不保留为1,传0表示要保留,只对普通数组有意义)
# 注意:linux下的uniq和其它语言的都是针对相邻重复行的去重,但是这里不是
array_uniq ()
{
    local -n _array_uniq_ref_arr="$1"
    if [[ -n "$2" ]] ; then
        local -n _array_uniq_ref_out_arr="$2"
    else
        local -a _array_uniq_ref_out_arr=()
    fi
    local -i _array_uniq_is_not_keep_index="${3:-1}"

    local -A _array_uniq_element_hash=()
    local _array_uniq_i

    for _array_uniq_i in "${!_array_uniq_ref_arr[@]}" ; do
        if ! ((_array_uniq_element_hash[${_array_uniq_ref_arr[$_array_uniq_i]}]++)) ; then
            _array_uniq_ref_out_arr[$_array_uniq_i]="${_array_uniq_ref_arr[$_array_uniq_i]}"
        fi
    done

    if((_array_uniq_is_not_keep_index)) ; then
        _array_uniq_ref_out_arr=("${_array_uniq_ref_out_arr[@]}")
    fi

    # 更新原数组
    if [[ -z "$2" ]] ; then
        _array_uniq_ref_arr=("${_array_uniq_ref_out_arr[@]}")
    fi
}

# 保持hash的值不重复(这个好像意义不大)
hash_uniq ()
{
    local -n _hash_uniq_ref_arr="$1"
    local -n _hash_uniq_ref_out_arr="$2"

    local -A _hash_uniq_element_hash=()
    local _hash_uniq_i

    for _hash_uniq_i in "${!_hash_uniq_ref_arr[@]}" ; do
        if ! ((_hash_uniq_element_hash[${_hash_uniq_ref_arr[$_hash_uniq_i]}]++)) ; then
            _hash_uniq_ref_out_arr[$_hash_uniq_i]="${_hash_uniq_ref_arr[$_hash_uniq_i]}"
        fi
    done
}


# :TODO: 过滤器
array_fillter ()
{
    :
}

# :TODO: 累加器？
array_reduce ()
{
    :
}


# 反转一个数组(:TODO:)
array_revert ()
{
    :
}

# 只要数组中的元素有一个能满足给定函数的要求，就返回真，否则返回假
# 需要给函数传递一个函数引用
# 1: 需要操作的数组的名字
# 2: 函数名
# @: 其它参数
# $: 当前迭代数据索引
#
# 空数组返回假(没有元素满足条件)
# (函数的这种行为是基于逻辑和数学中的约定，
# 特别是在处理空集合时的全称量化和存在量化的原则。)
array_any ()
{
    local -n _array_any_ref_arr="$1"
    local _array_any_function="$2"
    shift 2

    local _array_any_index
    for _array_any_index in "${!_array_any_ref_arr[@]}" ; do
        if "$_array_any_function" "${_array_any_ref_arr[$_array_any_index]}" "$_array_any_index" "${@}" ; then
            return 0
        fi
    done

    return 1
}

# 数组中所有元素都满足要求,返回 真,否则返回假
# 空数组返回真(没有元素违反条件)
# (函数的这种行为是基于逻辑和数学中的约定，
# 特别是在处理空集合时的全称量化和存在量化的原则。)
array_all ()
{
    local -n _array_all_ref_arr="$1"
    local _array_all_function="$2"
    shift 2

    local _array_all_index
    for _array_all_index in "${!_array_all_ref_arr[@]}" ; do
        if ! "$_array_all_function" "${_array_all_ref_arr[$_array_all_index]}" "$_array_all_index" "${@}" ; then
            return 1
        fi
    done

    return 0
}

# 如果数组中的每个元素都不满足条件,返回 真 ,否则返回假
# 空数组返回真(没有元素违反条件)
# (函数的这种行为是基于逻辑和数学中的约定，
# 特别是在处理空集合时的全称量化和存在量化的原则。)
array_none ()
{
    local -n _array_none_ref_arr="$1"
    local _array_none_function="$2"
    shift 2

    local _array_none_index
    for _array_none_index in "${!_array_none_ref_arr[@]}" ; do
        if "$_array_none_function" "${_array_none_ref_arr[$_array_none_index]}" "$_array_none_index" "${@}" ; then
            return 1
        fi
    done

    return 0
}

array_max ()
{
    :
}

array_min ()
{
    :
}

array_strmax ()
{
    :
}

array_strmin ()
{
    :
}


# 返回数组中满足一系列条件(可能不只一个)的第一个索引
# 所有的条件通过函数引用传递进来
array_first ()
{
    :
}

# 返回数组中满足一系列条件(可能不只一个)的第一个值
# 1: 数组引用
# 2: 条件函数
# @: 条件函数带的参数
array_first_value ()
{
    local -n _array_first_value_ref_arr="$1"
    local array_name="$1"
    local out_element=
    local _array_first_value_function="$2"
    shift 2

    local -a _array_first_value_params=("${@}")
    local _array_first_value_i

    for _array_first_value_i in "${!_array_first_value_ref_arr[@]}" ; do
        if "$_array_first_value_function" "${_array_first_value_ref_arr[$_array_first_value_i]}" "$_array_first_value_i" "${_array_first_value_params[@]}" ; then
            printf "%s" "${_array_first_value_ref_arr[$_array_first_value_i]}"
            break
        fi
    done
}



# 数组的顺时针轮转
array_rotate_right ()
{
    :
}

# 数组的逆时针轮转
array_rotate_left ()
{
    :
}


# hash模拟集合的交集
array_set_intersection ()
{
    :
}

# hash模拟集合的并集
array_set_union ()
{
    :
}

# hash模拟集合的差集
array_set_diff ()
{
    :
}

# hash模拟集合的补集
array_set_complement ()
{
    :
}


