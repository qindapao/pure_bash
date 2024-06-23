. ./meta/meta.sh
((DEFENSE_VARIABLES[array_uniq]++)) && return 0


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

return 0

