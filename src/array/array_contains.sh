. ./meta/meta.sh
((DEFENSE_VARIABLES[array_contains]++)) && return 0

# :TODO: 使用eval的实现
# 判断数组中是否包含某些元素
# 1:    数组的引用名字
# 2~$:  需要检查包含的元素(需要都包含才返回为真)
array_contains ()
{
    local -n _array_contains_ref_array=$1
    shift
    local _array_contains_elements=("${@}")
    local _array_contains_i _array_contains_j
    local -i _array_contains_is_exists=0
    
    for _array_contains_i in "${_array_contains_elements[@]}" ; do
        _array_contains_is_exists=0
        for _array_contains_j in "${_array_contains_ref_array[@]}" ; do
            [[ "$_array_contains_j" == "$_array_contains_i" ]] && {
                _array_contains_is_exists=1
                break
            }
        done
        ((_array_contains_is_exists)) || return 1
    done
    
    return 0
}

return 0

