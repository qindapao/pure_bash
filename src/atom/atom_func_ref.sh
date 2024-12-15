. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_func_ref]++)) && return 0

. ./cntr/cntr_copy.sh || return 1
. ./str/str_q_to_arr.sh || return 1

# 注意: 由于涉及到数组或者关联数组的拷贝,所以经过这个函数转换后效率降低
#       如果效率敏感,那么调用的函数还是应该用命名空间来优化重构
#       由于把原始的参数拷贝了,所以可能造成调试困难，一般情况下
#       不建议使用这个函数
#
# 1: 函数名
# 2: 传出变量名
# 3~n: 函数传出参数

# 函数的正常传参是这样的:
#   func -v ref1 -a ref2 -A ref3 -p para1 para2 para3
# 封装后的传参是这样的
#   atom_func_upstr -ov ret_xx -f \
#       func -v ref1 -a ref2 -A ref3 -p para1 para2 para3

atom_func_ref () 
{
    # 0: 退出变量属性
    # 1: 调用的函数名
    # 后面都保存的二元组(属性[字符串,数组,字典] 拷贝后的变量名)
    local -a _atom_func_ref_param_keep=()
    # 每个新变量名对应的原始变量名
    local -A _atom_func_ref_param_var_map=()
    # 每个新变量的属性
    local -A _atom_func_ref_param_var_atr=()
    local -i _atom_func_ref_param_var_cnt=1

    # 检查传入的参数是否有引用变量
    while(($#)) ; do
        case "$1" in
        -o[vaA])
            local REPLY=''
            _atom_func_ref_param_keep+=("$1" "$2")
            shift 2
            ;;
        -f)
            ((${#_atom_func_ref_param_keep[@]})) && _atom_func_ref_param_keep+=(-f "$2") || _atom_func_ref_param_keep=('' '' -f "$2")
            shift 2
            ;;
        -v)
            local REF_VAR_${_atom_func_ref_param_var_cnt}="${!2}"
            _atom_func_ref_param_keep+=("-v" "REF_VAR_${_atom_func_ref_param_var_cnt}")
            _atom_func_ref_param_var_map[REF_VAR_${_atom_func_ref_param_var_cnt}]="$2"
            _atom_func_ref_param_var_atr[REF_VAR_${_atom_func_ref_param_var_cnt}]='-v'
            shift 2
            ((_atom_func_ref_param_var_cnt++))
            ;;
        -a)
            eval "local -a REF_VAR_${_atom_func_ref_param_var_cnt}=()"
            _atom_func_ref_param_keep+=("-a" "REF_VAR_${_atom_func_ref_param_var_cnt}")
            _atom_func_ref_param_var_atr[REF_VAR_${_atom_func_ref_param_var_cnt}]='-a'
            ;;&
        -A)
            eval "local -A REF_VAR_${_atom_func_ref_param_var_cnt}=()"
            _atom_func_ref_param_keep+=("-A" "REF_VAR_${_atom_func_ref_param_var_cnt}")
            _atom_func_ref_param_var_atr[REF_VAR_${_atom_func_ref_param_var_cnt}]='-A'
            ;;&
        -[aA])
            cntr_copy REF_VAR_${_atom_func_ref_param_var_cnt} "$2"
            _atom_func_ref_param_var_map[REF_VAR_${_atom_func_ref_param_var_cnt}]="$2"
            shift 2
            ((_atom_func_ref_param_var_cnt++))
            ;;

        -p)
            break
            ;;

        esac
    done

    local _atom_func_ref_param_ret

    if [[ "${BASH_ALIASES[${_atom_func_ref_param_keep[3]}]:+set}" ]] ; then
        local _atom_func_ref_alias_arr=()
        str_q_to_arr _atom_func_ref_alias_arr "${BASH_ALIASES[${_atom_func_ref_param_keep[3]}]}"
        "${_atom_func_ref_alias_arr[@]}" "${_atom_func_ref_param_keep[@]:4}" "${@}"
    else
        ${_atom_func_ref_param_keep[3]} "${_atom_func_ref_param_keep[@]:4}" "${@}"
    fi
    _atom_func_ref_param_ret=$?

    # 还原上层的数据结构
    for item in "${!_atom_func_ref_param_var_map[@]}" ; do
        case "${_atom_func_ref_param_var_atr[$item]}" in
            -v)
                eval ${_atom_func_ref_param_var_map[$item]}='${!item}'
                ;;
            -[aA])
                cntr_copy ${_atom_func_ref_param_var_map[$item]} ${item}
                ;;
        esac
    done

    # 得到REPLY
    if [[ -n "${_atom_func_ref_param_keep[0]}" ]] ; then
        case "${_atom_func_ref_param_keep[0]}" in
            -ov)
                eval ${_atom_func_ref_param_keep[1]}='${REPLY}' ;;
            -oa)
                eval "${_atom_func_ref_param_keep[1]}=($REPLY)" ;;
            -oA)
                eval "local _atom_func_ref_kv=($REPLY)"
                dict_by_kv ${_atom_func_ref_param_keep[1]} _atom_func_ref_kv
                ;;
        esac
    fi

    return $_atom_func_ref_param_ret
}

return 0

