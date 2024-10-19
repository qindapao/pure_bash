# array

## 废弃的实现

一些淘汰的实现保存下，以供以后参考。


### array_revert_dense

```bash
忽略数组的索引翻转数组
原地翻转1个数组
array_revert_dense ()
{
    eval -- '((${#'$1'[@]})) || return 0'
    eval -- 'local -a tmp_'$1'=("${'$1'[@]}")'
    eval -- 'local -i tmp_'$1'_max_index=$((${#tmp_'$1'[@]}-1))'
    eval -- eval -- eval -- 'set -- \\\"'$1'\\\" \\\"$\\{tmp_'$1'[{$tmp_'$1'_max_index..0}]\\}\\\"'
    eval -- ''$1'=("${@:2}")'
    return 0
}
```

实现已经被更简洁的方式替代。

### array_filter

原始的实现不是那么安全，现在已经被更安全的方式替代，使用`eval`而不是间接引用更便于问题定位。当前的实现支持数组和关联数组，所以叫`cntr_grep`。

```bash
# 过滤掉某些数组中满足条件的元素，并且更新原数组(原数组处理后不是稀疏数组)
# 只考虑数组的情况(不考虑关联数组,关联数组用单独的函数处理)
# :TODO: index还有没有意义?这里数组的index可能已经改变
array_filter ()
{
    local -n _array_filter_ref_arr=$1
    local _array_filter_copy_arr=("${_array_filter_ref_arr[@]}")
    _array_filter_ref_arr=()
    # local _array_filter_function=${BASH_ALIASES[$2]-$2}
    local _array_filter_function=$2
    shift 2

    local _array_filter_i

    for _array_filter_i in "${!_array_filter_copy_arr[@]}" ; do
        if ! eval ${_array_filter_function} '"$_array_filter_i"' '"${_array_filter_copy_arr[$_array_filter_i]}"' '"${@}"' ; then
            _array_filter_ref_arr+=("${_array_filter_copy_arr["$_array_filter_i"]}")
        fi
    done
}
```

### array_grep

下面这个函数完全没有必要了，`array_filter`完全可以替代。

```bash
# 数组元素查找(不改变原始的数组)
# 1: 需要操作的数组引用
# 2: 输出的数组引用(满足条件的元素放这里,得到的数组不是稀疏数组)
# 3: 一个函数,第一个参数是当前的字符串,其它的参数为函数自带,最后一个参数是当前索引(可选,如果筛选函数需要使用数组索引)
# 返回值
# 真: 有元素捕捉到
# 假: 无元素捕捉到
array_grep ()
{
    local -n _array_grep_ref_arr=$1 _array_grep_ref_out_arr=$2
    _array_grep_ref_out_arr=()
    # local _array_grep_function=${BASH_ALIASES[$3]-$3}
    local _array_grep_function=$3
    shift 3
    local -a _array_grep_params=("${@}")
    local _array_grep_i
    
    for _array_grep_i in "${!_array_grep_ref_arr[@]}" ; do
        if eval ${_array_grep_function} '"$_array_grep_i"' '"${_array_grep_ref_arr[$_array_grep_i]}"' '"${_array_grep_params[@]}"'  ; then
            _array_grep_ref_out_arr[$_array_grep_i]=${_array_grep_ref_arr[$_array_grep_i]}
        fi
    done

    if ((${#_array_grep_ref_out_arr[@]})) ; then
        _array_grep_ref_out_arr=("${_array_grep_ref_out_arr[@]}")
        return 0
    fi
    return 1
}
```

### array_grep_block

`array_filter`已经包含了`array_grep_block`的功能了，不需要再单独弄一个函数。

```bash
# 使用匿名代码块来进行过滤
# :TODO: 待测试,如果block函数中有别名会怎么样?
array_grep_block ()
{
    # 这种情况下双引号就是必不可少的了
    local -n _array_grep_block_{ref_arr="$1",out_arr="$2"}
    _array_grep_block_out_arr=()
    local _array_grep_block_exec_block=$3

    eval "_array_grep_block_tmp_function() { "$_array_grep_block_exec_block" ; }"
    local _array_grep_block_index

    for _array_grep_block_index in "${!_array_grep_block_ref_arr[@]}" ; do
        if _array_grep_block_tmp_function "$_array_grep_block_index" "${_array_grep_block_ref_arr[$_array_grep_block_index]}" ; then
            _array_grep_block_out_arr[$_array_grep_block_index]="${_array_grep_block_ref_arr[$_array_grep_block_index]}"
        fi
    done

    unset -f _array_grep_block_tmp_function

    if((${#_array_grep_ref_out_arr[@]})) ; then
        _array_grep_block_out_arr=("${_array_grep_block_out_arr[@]}")
        return 0
    fi
    return 1
}
```

### array_map

`array_map`使用更通用的实现`cntr_map`，兼容参数传参，下面的实现备份。

```bash
# 数组的map函数，对数组中的每个元素执行特定的函数
# 1: 需要操作的数组的名字
# 2: 函数名(提供一个操作函数,这个函数依次作用于每个数组元素并改变它)
#           
# @: 其它参数为这个函数需要的参数(函数的第一个参数默认为当前数组元素的索引,第二个参数默认为数组元素)
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
    local -n _array_map_ref_arr=$1
    # local _array_map_function=${BASH_ALIASES[$2]-$2}
    local _array_map_function=$2
    shift 2
    local _array_map_function_params=("${@}")
    local _array_map_index
    for _array_map_index in "${!_array_map_ref_arr[@]}" ; do
        _array_map_ref_arr[$_array_map_index]=$(eval ${_array_map_function} '"$_array_map_index"' '"${_array_map_ref_arr[$_array_map_index]}"' '"${_array_map_function_params[@]}"')
    done
}
```

### array_map_block

使用`cntr_map`完全可以替代，所以这个函数不需要。

```bash
# 执行一个匿名函数
# $ array_map_block a "$(cat <<-'EOF'
# local x=$1 ;
# printf "%s" $((x+1)) ;
# EOF  
# )" 
#
# 1: 需要迭代操作的数据引用
# 2: 执行的匿名代码块
# :TODO: 待测试,如果block函数中包含别名的情况
array_map_block ()
{
    local -n _array_map_block_ref_arr=$1
    local _array_map_block_exec_block=$2 
    
    eval "_array_map_block_tmp_function() { "$_array_map_block_exec_block" ; }"
    local _array_map_block_index

    for _array_map_block_index in "${!_array_map_block_ref_arr[@]}" ; do
        _array_map_block_ref_arr[$_array_map_block_index]=$(_array_map_block_tmp_function "$_array_map_block_index" "${_array_map_block_ref_arr[$_array_map_block_index]}")
    done

    unset -f _array_map_block_tmp_function
}
```

### array_map_readonly


使用`cntr_map`完全可以替代，所以这个函数不需要。

```bash
# 对映射的每个数组元素进行操作,但是不改变原数组
array_map_readonly ()
{
    local -n array_map_readonly_ref_arr=$1
    # local array_map_readonly_function=${BASH_ALIASES[$2]-$2}
    local array_map_readonly_function=$2
    shift 2
    local array_map_readonly_function_params=("${@}")
    local array_map_readonly_index
    for array_map_readonly_index in "${!array_map_readonly_ref_arr[@]}" ; do
        eval ${array_map_readonly_function} '"$array_map_readonly_index"' '"${array_map_readonly_ref_arr[$array_map_readonly_index]}"' '"${array_map_readonly_function_params[@]}"'
    done
}
```

### array_map_readonly_block

使用`cntr_map`完全可以替代，所以这个函数不需要。

```bash
# 执行匿名代码块不改变原始数组
# :TODO: 待测试,block临时函数中包含别名的情况
array_map_readonly_block ()
{
    local -n array_map_readonly_block_ref_arr=$1
    local array_map_readonly_block_exec_block=$2 
    
    eval "array_map_readonly_block_tmp_function() { "$array_map_readonly_block_exec_block" ; }"
    local array_map_readonly_block_index

    for array_map_readonly_block_index in "${!array_map_readonly_block_ref_arr[@]}" ; do
        array_map_readonly_block_tmp_function "$array_map_readonly_block_index" "${array_map_readonly_block_ref_arr[$array_map_readonly_block_index]}"
    done

    unset -f array_map_readonly_block_tmp_function
}
```

### array_all

另外实现了，这个老实现函数先备份

```bash
# 数组中所有元素都满足要求,返回 真,否则返回假
# 空数组返回真(没有元素违反条件)
# (函数的这种行为是基于逻辑和数学中的约定，
# 特别是在处理空集合时的全称量化和存在量化的原则。)
# 子函数第一个参数为数组索引
#       第二个参数为数组值
#
array_all ()
{
    local -n _array_all_ref_arr=$1
    # local _array_all_function=${BASH_ALIASES[$2]-$2}
    # 不管是函数还是别名,用eval都只能直接执行
    local _array_all_function=$2
    shift 2

    local _array_all_index
    for _array_all_index in "${!_array_all_ref_arr[@]}" ; do
        # 双引号外面包裹一层单引号
        if ! eval ${_array_all_function} '"$_array_all_index"' '"${_array_all_ref_arr[$_array_all_index]}"' '"${@}"' ; then
            return 1
        fi
    done

    return 0
}
```

### array_copy

废弃的实现，主要实现更加好，不用改IFS变量。

```bash
# 下面是设置IFS为空的版本,但是上面的更好,调试eval执行代码最好的方式是使用
# set -xv选项看到bash代码展开和执行的细节
array_copy ()
{
    local IFS='' 
    local _array_copy_script_${1}${2}='
        '$1'=()
        local i'$1$2'
        for i'$1$2' in "${!'$2'[@]}"; do
          '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
        done'

    # 只有在IFS=''的时候才可以正常工作
    # 如果只有一个eval就没有这个要求
    # 需要确保字符串中的空格不会被解释为分隔符。因此，设置 IFS='' 
    # 可以避免潜在的问题。
    eval -- eval -- "$"_array_copy_script_${1}${2}""
}
```

