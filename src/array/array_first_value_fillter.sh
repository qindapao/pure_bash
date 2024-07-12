. ./meta/meta.sh
((DEFENSE_VARIABLES[array_first_value_fillter]++)) && return 0


# 返回数组中满足一系列条件(可能不只一个)的第一个值,同时按照条件函数打印的信息返回(满足条件然后过滤)
# 约定打印的值以回车分隔每一个(过滤函数可以返回多个值),过滤函数以返回值0 1表示成功失败,打印信息用于返回字符串
array_first_value_fillter ()
{
    local -n _array_first_value_fillter_ref_arr=$1
    # local _array_first_value_fillter_function=${BASH_ALIASES[$2]-$2}
    local _array_first_value_fillter_function=$2
    shift 2

    local _array_first_value_fillter_i get_value
    
    for _array_first_value_fillter_i in "${!_array_first_value_fillter_ref_arr[@]}" ; do
        get_value=$(eval ${_array_first_value_fillter_function} '"$_array_first_value_fillter_i"' '"${_array_first_value_fillter_ref_arr[$_array_first_value_fillter_i]}"' '"$@"')
        (($?)) || { printf "%s" "$get_value" ; break ; }
    done
}

return 0

