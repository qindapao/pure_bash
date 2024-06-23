. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_load]++)) && return 0

. ./struct/struct_set_field.sh || return 1

# . ./log/log_dbg.sh || return 1

# 从一个配置中还原成一个结构体数据结构,配置的约定
# 去掉文件前后的空行和全是空格的行
# 第一行去掉最后两个字符,前面是变量的名字(实际可以不关心)
# 从第二行开始,首先解析键,如果键的最后一个字符是空格,那么证明下一行一定有值
#   取值:直接获取下一行完整内容,然后去掉当前层级的缩进空格字符串,得到值(是数组还是关联数组，由上面键的符号决定),然后把Q字符串还原成正常字符串
# 如果遇到的键的最后一个字符不是空格,是⩦或者⇒,那么压到栈中(索引树),栈中要保存当前数据结构是数组还是关联数组
# 继续往下查找,直到最后一行
# 键和值一定是一一对应的，不存在空键,就算空键也会有一个''
# :TODO: 很有挑战性,解析json?但是有点问题,我的数据结构要求必须有叶子节点,但是json不一定,json可以有空数组或者空hash
# son_dict ⇒
#     qin1 ⇒ 
#     va1
#     qin2 ⇒
#         0 ⩦
#             1 ⩦ 
#             va1
#             2 ⩦ 
#             va1
#         1 ⩦ 
#         va1
#     qin3 ⇒
#         xxhou ⇒ 
#         va1
#     qin4 ⇒
#         xxxian ⇒ 
#         va2
# 

# 缩进增加的时候键一直往栈里面压,缩进减少的时候键往外弹，减少几个缩进弹几个，然后把当前键加入栈
# 缩进的数量可以通过计算当前行的前导空格数量/4得到，这个值和栈里面键的数量比较即可
struct_load ()
{
    # 变量的数据类型必须外面定义
    local -n _struct_load_struct_out_ref="${1}"
    
    _struct_load_struct_out_ref=()

    local _struct_load_struct_input_file_path="${2}"
    local -a _struct_load_struct_file_contents=()
    local -a _struct_load_struct_file_contents_tmp=()
    local -a _struct_load_key_stack=()
    local _struct_load_line_last_char=''
    local _struct_load_line_cnt=''
    local _struct_load_line_content=''
    local _struct_load_value='' _struct_load_key='' _struct_load_ori_str=''
    local _struct_load_leaf_set_key=''
    local -i _struct_load_lev=0 _struct_load_pop_cnt=0

    mapfile -t _struct_load_struct_file_contents_tmp < "$_struct_load_struct_input_file_path"
    for _struct_load_line_content in "${_struct_load_struct_file_contents_tmp[@]}" ; do
        # 删除存空行和全是空白字符的行
        if [[ ! "$_struct_load_line_content" =~ ^[[:space:]]*$ ]] ; then
            _struct_load_struct_file_contents+=("$_struct_load_line_content")
        fi
    done

    # 每个孤键的类型由栈里面的最后一个元素决定
    _struct_load_line_last_char="${_struct_load_struct_file_contents[0]: -1}"

    for((_struct_load_line_cnt=1;_struct_load_line_cnt<${#_struct_load_struct_file_contents[@]};)) ; do
        _struct_load_lev=0
        _struct_load_line_content="${_struct_load_struct_file_contents[_struct_load_line_cnt]}"

        [[ "$_struct_load_line_content" =~ ^(\ *) ]] && {
            _struct_load_lev=${#BASH_REMATCH[1]}
            ((_struct_load_lev/=4))
            ((_struct_load_lev--))
        }

        if ((_struct_load_lev<${#_struct_load_key_stack[@]})) ; then
            # 先弹出多余的键
            ((_struct_load_pop_cnt=${#_struct_load_key_stack[@]}-_struct_load_lev))
            _struct_load_key_stack=("${_struct_load_key_stack[@]::${#_struct_load_key_stack[@]}-_struct_load_pop_cnt}")
        fi

        _struct_load_key="${_struct_load_line_content#"${_struct_load_line_content%%[! ]*}"}"
        # 判断最后一个字符是否是空格确定是否是叶子节点
        _struct_load_line_last_char="${_struct_load_line_content: -1}"

        if [[ ' ' == "$_struct_load_line_last_char" ]] ; then
            # 先取key字符,和栈里面组合成的键一起设置数据结构
            _struct_load_value="${_struct_load_struct_file_contents[_struct_load_line_cnt+1]}"
            _struct_load_value="${_struct_load_value#"${_struct_load_value%%[! ]*}"}"  

            # key和value都要从Q字符串转换成常规字符串(最后三个字符不能转,它们不属于Q字符串 ⇒ )
            eval "_struct_load_ori_str=${_struct_load_key:0:-3}"
            eval "_struct_load_value=$_struct_load_value"

            _struct_load_leaf_set_key="${_struct_load_key: -2:1}"


            if [[ "${_struct_load_leaf_set_key}" == '⇒' ]] ; then
                _struct_load_leaf_set_key="[${_struct_load_ori_str}]"
            else
                _struct_load_leaf_set_key="${_struct_load_ori_str}"
            fi

            struct_set_field '_struct_load_struct_out_ref' "${_struct_load_key_stack[@]}" "${_struct_load_leaf_set_key}" '' "$_struct_load_value"

            ((_struct_load_line_cnt+=2))
        else
            # key从Q字符串转换成常规字符串(最后两个字符不能转,它们不属于Q字符串 ⇒)
            eval "_struct_load_ori_str=${_struct_load_key:0:-2}"

            if [[ "${_struct_load_key: -1}" == '⇒' ]] ; then
                _struct_load_key_stack+=("[${_struct_load_ori_str}]")
            else
                _struct_load_key_stack+=("${_struct_load_ori_str}")
            fi
            
            ((_struct_load_line_cnt++))
        fi
    done
}

return 0

