# :TODO: 操作引用变量的函数和不操作引用变量的函数需要区分开，目前混淆在一起的
# 数组操作集合(模拟perl5的行为)

# 命令行参数有大小限制，不能太大
# 为了防止有引用变量的情况下的变量污染,所有带引用变量的库函数都以_函数名_打头
# 所有 : 的函数都是暂时未实现的


# :TODO: 建议使用一个统一的hash表来管理所以的头部防御变量,方便日志函数统一处理
. ./meta.sh
((DEFENSE_VARIABLES[array]++)) && return

. ./atom.sh
. ./str.sh

# 这个函数并没有用,直接操作更简单
array_push ()
{
    local -n _array_push_ref_arr="$1"
    shift
    _array_push_ref_arr+=("${@}")
}

# 这个函数几乎无用
# 往数组的头部添加元素(添加的元素可以是数组,不能是稀疏数组)
# 命令行参数有大小限制，不能太大
# 可以处理稀疏数组，但是效率不高
array_unshift ()
{
    local -n _array_unshift_ref_arr="${1}"
    shift
    local -a _array_unshift_new_arr=("${@}")
    local -i _array_unshift_i
    local -i _array_unshift_new_arr_cnt=${#_array_unshift_new_arr[@]}
    for _array_unshift_i in "${!_array_unshift_ref_arr[@]}" ; do
        _array_unshift_new_arr[_array_unshift_i+_array_unshift_new_arr_cnt]="${_array_unshift_ref_arr[_array_unshift_i]}"
    done
    
    _array_unshift_ref_arr=()

    for _array_unshift_i in "${!_array_unshift_new_arr[@]}" ; do
        _array_unshift_ref_arr[_array_unshift_i]="${_array_unshift_new_arr[_array_unshift_i]}"
    done
}

# 这个函数也没有用,直接操作更简单
# 把数组都按照稀疏数组处理(添加的元素可以是数组,不能是稀疏数组)t
# 不能处理稀疏数组，效率高，这个函数也是没什么用，直接操作即可
array_unshift_dense ()
{
    local -n _array_unshift_dense_ref_arr="${1}"
    shift
    _array_unshift_dense_ref_arr=("${@}" "${_array_unshift_dense_ref_arr[@]}")
}

# 这个函数也无用,直接操作更简单
# 删除数组的最后一个元素并且返回
# 使用方法 element=$(array_pop "arr_name")
array_pop ()
{
    local -n _array_pop_ref_arr="${1}"
    local _array_pop_ref_pop_element=
    ((${#_array_pop_ref_arr[@]})) || return 
    
    _array_pop_ref_pop_element="${_array_pop_ref_arr[-1]}"
    # 这个语法bash4.3才支持,数据的负向索引是从4.3才开始引入的
    unset '_array_pop_ref_arr[-1]'
    printf "%s" "$_array_pop_ref_pop_element"
}

# 删除数组的第一个元素并且返回,支持稀疏数组与非稀疏
# 使用方法 element=$(array_shift "arr_name")
# :TODO: 目前有一个问题,$(function xx yy)这种调用方式是在子shell中执行的,因此
#        无法更改父shell环境中的数组,所以原始的数组无法被更新,需要调用两次函数解决
#        first_element=$(array_shift my_arr)
#        array_shift
#        但是这样感觉很冗余了
#        如果通过引用变量传递需要获取的元素又无法在命令替换的$()中使用,用起来不方便
#        鱼和熊掌不可兼得!
array_shift ()
{
    local -n _array_shift_ref_arr="${1}"
    local array_shift_shift_element=
    local _array_shift_indexs=("${!_array_shift_ref_arr[@]}")
    ((${#_array_shift_indexs[@]})) || return
    local _array_shift_first_index=${_array_shift_indexs[0]}
    
    array_shift_shift_element="${_array_shift_ref_arr[_array_shift_first_index]}"
    unset '_array_shift_ref_arr[_array_shift_first_index]'
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

# 数组按照稀疏数组处理,性能更高
array_shift_dense ()
{
    local -n _array_shift_dense_ref_arr="${1}"
    ((${#_array_shift_dense_ref_arr[@]})) || return

    local _array_shift_dense_first_element="${_array_shift_dense_ref_arr[@]:0:1}"
    _array_shift_dense_ref_arr=("${_array_shift_dense_ref_arr[@]:1}")
    printf "%s" "$_array_shift_dense_first_element"
}

# 取数组的第一个元素，但是不删除它(对应 shift)
# 这是考虑稀疏数组的情况,如果是要取索引0,直接arr[0]即可
# 这个函数好像意义也不大,直接${arr[@]:0:1}更简洁直接
array_peek ()
{
    local -n _array_peek_ref_arr="${1}"
    printf "%s" "${_array_peek_ref_arr[@]:0:1}"
}

# 取数组的最后一个元素，但是不删除它(对应 pop)
# 这个函数意义不大,直接用${arr[-1]}更好
array_tail ()
{
    local -n _array_tail_ref_arr="${1}"
    ((${#_array_tail_ref_arr[@]})) || return

    printf "%s" "${_array_tail_ref_arr[-1]}"
}

# 数组元素查找(不改变原始的数组)
# 1: 需要操作的数组引用
# 2: 输出的数组引用(满足条件的元素放这里,得到的数组不是稀疏数组)
# 3: 一个函数,第一个参数是当前的字符串,其它的参数为函数自带,最后一个参数是当前索引(可选,如果筛选函数需要使用数组索引)
# 返回值
# 真: 有元素捕捉到
# 假: 无元素捕捉到
array_grep ()
{
    local -n _array_grep_ref_arr="${1}" _array_grep_ref_out_arr="${2}"
    _array_grep_ref_out_arr=()
    local _array_grep_function="${3}"
    shift 3
    local -a _array_grep_params=("${@}")
    local _array_grep_i
    
    for _array_grep_i in "${!_array_grep_ref_arr[@]}" ; do
        if "$_array_grep_function" "${_array_grep_ref_arr["$_array_grep_i"]}" "$_array_grep_i" "${_array_grep_params[@]}"  ; then
            _array_grep_ref_out_arr["$_array_grep_i"]="${_array_grep_ref_arr["$_array_grep_i"]}"
        fi
    done

    if ((${#_array_grep_ref_out_arr[@]})) ; then
        _array_grep_ref_out_arr=("${_array_grep_ref_out_arr[@]}")
        return 0
    fi
    return 1
}

# 使用匿名代码块来进行过滤
array_grep_block ()
{
    local -n _array_grep_block_ref_arr="${1}" _array_grep_block_out_arr="${2}"
    _array_grep_block_out_arr=()
    local _array_grep_block_exec_block="${3}"

    eval "_array_grep_block_tmp_function() { "$_array_grep_block_exec_block" ; }"
    local _array_grep_block_index

    for _array_grep_block_index in "${!_array_grep_block_ref_arr[@]}" ; do
        if _array_grep_block_tmp_function "${_array_grep_block_ref_arr["$_array_grep_block_index"]}" "$_array_grep_block_index" ; then
            _array_grep_block_out_arr["$_array_grep_block_index"]="${_array_grep_block_ref_arr["$_array_grep_block_index"]}"
        fi
    done

    unset -f _array_grep_block_tmp_function

    if((${#_array_grep_ref_out_arr[@]})) ; then
        _array_grep_block_out_arr=("${_array_grep_block_out_arr[@]}")
        return 0
    fi
    return 1
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
    local -n _array_map_ref_arr="${1}"
    local _array_map_function="${2}"
    shift 2
    local _array_map_function_params=("${@}")
    local _array_map_index
    for _array_map_index in "${!_array_map_ref_arr[@]}" ; do
        _array_map_ref_arr[$_array_map_index]=$("$_array_map_function" "${_array_map_ref_arr["$_array_map_index"]}" "$_array_map_index" "${_array_map_function_params[@]}")
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
    local -n _array_map_block_ref_arr="${1}"
    local _array_map_block_exec_block="${2}" 
    
    eval "_array_map_block_tmp_function() { "$_array_map_block_exec_block" ; }"
    local _array_map_block_index

    for _array_map_block_index in "${!_array_map_block_ref_arr[@]}" ; do
        _array_map_block_ref_arr[$_array_map_block_index]=$(_array_map_block_tmp_function "${_array_map_block_ref_arr["$_array_map_block_index"]}" "$_array_map_block_index")
    done

    unset -f _array_map_block_tmp_function
}

# 对映射的每个数组元素进行操作,但是不改变原数组
array_map_readonly ()
{
    local -n array_map_readonly_ref_arr="${1}"
    local array_map_readonly_function="${2}"
    shift 2
    local array_map_readonly_function_params=("${@}")
    local array_map_readonly_index
    for array_map_readonly_index in "${!array_map_readonly_ref_arr[@]}" ; do
        "$array_map_readonly_function" "${array_map_readonly_ref_arr["$array_map_readonly_index"]}" "$array_map_readonly_index" "${array_map_readonly_function_params[@]}"
    done
}

# 执行匿名代码块不改变原始数组
array_map_readonly_block ()
{
    local -n array_map_readonly_block_ref_arr="${1}"
    local array_map_readonly_block_exec_block="${2}" 
    
    eval "array_map_readonly_block_tmp_function() { "$array_map_readonly_block_exec_block" ; }"
    local array_map_readonly_block_index

    for array_map_readonly_block_index in "${!array_map_readonly_block_ref_arr[@]}" ; do
        array_map_readonly_block_tmp_function "${array_map_readonly_block_ref_arr["$array_map_readonly_block_index"]}" "$array_map_readonly_block_index"
    done

    unset -f array_map_readonly_block_tmp_function
}

# 排序一个数组中的元素(只能用于普通数组),关联数组没有顺序无法排序
# 规则:默认按照字典序排序
# 算法:当前使用冒泡排序算法
# 1: 需要排序数组引用名
_array_sort ()
{
    local -n __array_sort_ref_arr="${1}"
    local __array_sort_mark="${2}" __array_sort_delimiter="${3}" __array_sort_field="${4}"
    declare -a __array_sort_arr_indexs=("${!__array_sort_ref_arr[@]}")
    ((${#__array_sort_arr_indexs[@]})) || return 

    local -a __array_sort_tmp_arr=("${__array_sort_ref_arr[@]}")
    local -a __array_sort_tmp_arr_filed=("${__array_sort_ref_arr[@]}")

    # 如果有分隔符和域段,那么取它们作为子数组来排序
    if [[ -n "$__array_sort_delimiter" && -n "$__array_sort_field" ]] ; then
        # str_split_pure "<" "2" < <(printf "%s" "$1") 也可以
        array_map_block __array_sort_tmp_arr_filed "str_split \""$__array_sort_delimiter"\" \""$__array_sort_field"\" < <(printf \"%s\" \"\$1\")"
    fi

    local -i __array_sort_tmp_arr_size=${#__array_sort_tmp_arr[@]}

    local -i __array_sort_i __array_sort_j
    local __array_sort_tmp

    for ((__array_sort_i = 0; __array_sort_i < __array_sort_tmp_arr_size; __array_sort_i++)); do
        for ((__array_sort_j = 0; __array_sort_j < __array_sort_tmp_arr_size-$__array_sort_i-1; __array_sort_j++)); do
            if eval [[ "\"${__array_sort_tmp_arr_filed[__array_sort_j]}\"" "${__array_sort_mark}" "\"${__array_sort_tmp_arr_filed[__array_sort_j+1]}\"" ]] ; then
                __array_sort_tmp="${__array_sort_tmp_arr[__array_sort_j]}"
                __array_sort_tmp_arr[__array_sort_j]="${__array_sort_tmp_arr[__array_sort_j+1]}"
                __array_sort_tmp_arr[__array_sort_j+1]="$__array_sort_tmp"
            fi
        done
    done
    
    # 还原原始数组的索引(因为可能是个稀疏数组)
    __array_sort_j=0
    for __array_sort_i in "${__array_sort_arr_indexs[@]}" ; do
        __array_sort_ref_arr[__array_sort_i]="${__array_sort_tmp_arr[__array_sort_j++]}"
    done
}

# 1: 需要排序的数组
# 2: 排序mark(> < gt lt)
#       >: 字典升序(默认)
#       <: 字典降序
#       -gt: 数字升序
#       -lt: 数字降序
# 3: 分割符
# 4: 域段
# ...
# ... 一直往下循环组成,每组三个元素(可以看成三个元素的元组)
array_sort ()
{
    local -n _array_sort_ref_arr="${1}"
    shift
    
    (($#)) || {
        # 默认字典升序
        _array_sort _array_sort_ref_arr '>'
    }

    while (($#)) ; do
        _array_sort _array_sort_ref_arr "${1}" "${2}" "${3}"
        (($#)) && shift
        (($#)) && shift
        (($#)) && shift
    done
}


# 读取文件中的所有行并追加到一个数组中
array_read_file ()
{
    local -n _array_read_file_ref_arr="${1}"
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
array_is_array ()
{
    atom_identify_data_type "${1}" "a" && return 0 || return 1
}

# 去重多个数组中的重复元素,并且更新原数组,不保留原始的index
array_uniq_multi ()
{
    while(($#)) ; do
        local -n _array_uniq_multi_ref_arr="${1}"
        array_uniq _array_uniq_multi_ref_arr
        shift
    done
}

# 去重一个数组中的元素,最后返回一个新的去重后的数组
# 1: 需要去重的数组的引用名
# 2: 去重后保存的数组名(如果这个参数为空表示直接更新原数组)
# 3: 是否保留原始的index(默认不保留为1,传0表示要保留,只对普通数组有意义)
# 注意:linux下的uniq和其它语言的都是针对相邻重复行的去重,但是这里不是
array_uniq ()
{
    local -n _array_uniq_ref_arr="${1}"
    if [[ -n "$2" ]] ; then
        local -n _array_uniq_ref_out_arr="${2}"
    else
        local -a _array_uniq_ref_out_arr=()
    fi
    local -i _array_uniq_is_not_keep_index="${3:-1}"

    local -A _array_uniq_element_hash=()
    local _array_uniq_i

    for _array_uniq_i in "${!_array_uniq_ref_arr[@]}" ; do
        local _array_uniq_tmp_key="${_array_uniq_ref_arr["$_array_uniq_i"]}"
        # :TODO: 这里空元素被直接干掉了是否合理？
        [[ -z "$_array_uniq_tmp_key" ]] && continue
        
        # 方括号中用-v和双圆括号中要特别小心参数扩展的问题
        # 当前hash判断键是很危险的,使用单引号才能防止以外解释
        # :TODO: 这个问题要去社区求助下
        # 验证字符串
        # xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)
        # 下面这种写法和[[ -v _array_uniq_element_hash['$_array_uniq_tmp_key'] ]] 这里单双引号嵌套环境不一样表现不太一样，最好别用
        # if ((_array_uniq_element_hash['$_array_uniq_tmp_key']++)) ; then
        #     _array_uniq_ref_out_arr["$_array_uniq_i"]="${_array_uniq_tmp_key}"
        # fi
        # 
        # 可以使用下面的代码验证
        # declare -A k=(["(xx:yy)"]="6" ["xxx->xxx->xxx->xx:xx.x-/dev/fd/61-/dev/fd/60"]="1" ["xxx xxx->xxx->xxx->xx:xx.x-/dev/fd/61-/dev/fd/60"]="1" ["xxx xxx->xxx
        # ->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"]="2" )
        # tmp_key="xxx xxx->xxx->xxx->xx:xx.x->(xxx:xx)->(xxxxx:xxxx)"
        # if [[ -v k['$tmp_key'] ]] ; then echo xx; fi
        # if ((k['$tmp_key']++)) ; then echo xx; fi

        if [[ -z "${_array_uniq_element_hash["${_array_uniq_tmp_key}"]}" ]] ; then
            _array_uniq_element_hash["${_array_uniq_tmp_key}"]=1
            _array_uniq_ref_out_arr["$_array_uniq_i"]="${_array_uniq_tmp_key}"
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


# 过滤掉某些数组中满足条件的元素，并且更新原数组(原数组处理后不是稀疏数组)
# 只考虑数组的情况(不考虑关联数组,关联数组用单独的函数处理)
# :TODO: index还有没有意义?这里数组的index可能已经改变
array_filter ()
{
    local -n _array_filter_ref_arr="${1}"
    local _array_filter_copy_arr=("${_array_filter_ref_arr[@]}")
    _array_filter_ref_arr=()
    local _array_filter_function="${2}"
    shift 2

    local _array_filter_i

    for _array_filter_i in "${!_array_filter_copy_arr[@]}" ; do
        if ! "$_array_filter_function" "${_array_filter_copy_arr["$_array_filter_i"]}" "$_array_filter_i" "${@}" ; then
            _array_filter_ref_arr+=("${_array_filter_copy_arr["$_array_filter_i"]}")
        fi
    done
}

# :TODO: 累加器？
array_reduce ()
{
    :
}


# 保持数组的索引不变
array_revert ()
{
    local -n _array_revert_ref_arr="${1}"
    
    local _array_revert_arr_size="${#_array_revert_ref_arr[@]}"
    ((_array_revert_arr_size)) || return

    local -a _array_revert_tmp_arr=("${_array_revert_ref_arr[@]}")
    local -a _array_revert_indexs=("${!_array_revert_ref_arr[@]}")

    local _array_revert_index

    for((_array_revert_index=0;_array_revert_index<_array_revert_arr_size;_array_revert_index++)) ; do
        _array_revert_ref_arr[${_array_revert_indexs[_array_revert_index]}]="${_array_revert_tmp_arr[_array_revert_arr_size-_array_revert_index-1]}"
    done
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
    local -n _array_any_ref_arr="${1}"
    local _array_any_function="${2}"
    shift 2

    local _array_any_index
    for _array_any_index in "${!_array_any_ref_arr[@]}" ; do
        if "$_array_any_function" "${_array_any_ref_arr["$_array_any_index"]}" "$_array_any_index" "${@}" ; then
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
    local -n _array_all_ref_arr="${1}"
    local _array_all_function="${2}"
    shift 2

    local _array_all_index
    for _array_all_index in "${!_array_all_ref_arr[@]}" ; do
        if ! "$_array_all_function" "${_array_all_ref_arr["$_array_all_index"]}" "$_array_all_index" "${@}" ; then
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
    local -n _array_none_ref_arr="${1}"
    local _array_none_function="${2}"
    shift 2

    local _array_none_index
    for _array_none_index in "${!_array_none_ref_arr[@]}" ; do
        if "$_array_none_function" "${_array_none_ref_arr["$_array_none_index"]}" "$_array_none_index" "${@}" ; then
            return 1
        fi
    done

    return 0
}

# 非引用传递函数
# 求数组中按照数字排序最大的元素
# @: 整个数组的参数
array_max ()
{
    local max_var="${1}"
    shift
    local i
    for i in "${@}" ; do
        [[ "$i" -gt "$max_var" ]] && max_var="$i"
    done
    printf "%s" "$max_var"
}

# 非引用传递函数
# 求数组中按照数字排序最小的元素
# @: 整个数组的参数
array_min ()
{
    local min_var="${1}"
    shift
    local i
    for i in "${@}" ; do
        [[ "$i" -lt "$min_var" ]] && min_var="$i"
    done
    printf "%s" "$min_var"
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
    local -n _array_first_value_ref_arr="${1}"
    local _array_first_value_function="${2}"
    shift 2

    local _array_first_value_i

    for _array_first_value_i in "${!_array_first_value_ref_arr[@]}" ; do
        if "$_array_first_value_function" "${_array_first_value_ref_arr["$_array_first_value_i"]}" "$_array_first_value_i" "${@}" ; then
            printf "%s" "${_array_first_value_ref_arr["$_array_first_value_i"]}"
            break
        fi
    done
}

# 返回数组中满足一系列条件(可能不只一个)的第一个值,同时按照条件函数打印的信息返回(满足条件然后过滤)
# 约定打印的值以回车分隔每一个(过滤函数可以返回多个值),过滤函数以返回值0 1表示成功失败,打印信息用于返回字符串
array_first_value_fillter ()
{
    local -n _array_first_value_fillter_ref_arr="${1}"
    local _array_first_value_fillter_function="${2}"
    shift 2

    local _array_first_value_fillter_i get_value
    
    for _array_first_value_fillter_i in "${!_array_first_value_fillter_ref_arr[@]}" ; do
        get_value=$("$_array_first_value_fillter_function" "${_array_first_value_fillter_ref_arr["$_array_first_value_fillter_i"]}" "$_array_first_value_fillter_i" "$@")
        (($?)) || { printf "%s" "$get_value" ; break ; }
    done
}


# 数组的轮转(不改变索引)
# 1: 需要操作的数组引用
# 2: 旋转步长
#       正数: 向左旋转一个给定步长
#       负数: 向右旋转一个给定步长(顺时针,最后元素变成最前元素)
array_rotate ()
{
    local -n _array_rotate_ref_arr="${1}"
    local -i _array_rotate_step="${2}"
    local -i _array_rotate_arr_size=${#_array_rotate_ref_arr[@]}
    
    ((_array_rotate_arr_size)) || return
    local -a _array_rotate_arr_indexs=("${!_array_rotate_ref_arr[@]}")
    local -a _array_rotate_arr_tmp_arr=("${_array_rotate_ref_arr[@]}")
    
    local _array_rotate_index
    for((_array_rotate_index=0;_array_rotate_index<_array_rotate_arr_size;_array_rotate_index++)) ; do
        _array_rotate_ref_arr[${_array_rotate_arr_indexs[_array_rotate_index]}]=${_array_rotate_arr_tmp_arr[(_array_rotate_index+_array_rotate_step)%_array_rotate_arr_size]}
    done
}


# :TODO: 从数组中删除一个元素(删除后的数组索引保留吗？或者提供两种函数，保留索引的，和致密的)
array_delete_elements ()
{
    :
}

# 不保留索引,删除后的数组是一个致密数组(稀疏输入进来,也转换成致密数组)
# 1: 需要处理的数组引用
# 2~@: 需要删除的元素的值
array_del_elements_dense ()
{
    local -n _array_del_elements_dense_ref_arr="${1}"
    local -a _array_del_elements_dense_copy_arr=()
    shift
    local _array_del_elements_delete_value _array_del_elements_delete_arr_value

    for _array_del_elements_delete_value in "${@}" ; do
        _array_del_elements_dense_copy_arr=("${_array_del_elements_dense_ref_arr[@]}")
        _array_del_elements_dense_ref_arr=()
        for _array_del_elements_delete_arr_value in "${_array_del_elements_dense_copy_arr[@]}" ; do
            if [[ "$_array_del_elements_delete_arr_value" != "$_array_del_elements_delete_value" ]] ; then
                _array_del_elements_dense_ref_arr+=("$_array_del_elements_delete_arr_value")
            fi
        done
    done
}

# :TODO: 一种利用参数扩展连续给数组赋值的方法,不知道有什么用
# let 'a['{1..4}']=2'
# eval let 'a['{1.."$x"}']=2'
# eval "declare -a a[{1..$x}]=xxxgege"

# :TODO: 数组是否需要实现集合的4种操作?

