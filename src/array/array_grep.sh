. ./meta/meta.sh
((DEFENSE_VARIABLES[array_grep]++)) && return 0

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

return 0

