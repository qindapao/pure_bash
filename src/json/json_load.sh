. ./meta/meta.sh
((DEFENSE_VARIABLES[json_load]++)) && return 0

. ./json/json_set.sh || return 1

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
json_load ()
{
    # 变量的数据类型必须外面定义
    local -n _json_load_json_out_ref=$1
    
    _json_load_json_out_ref=()

    local _json_load_json_input_file_path=$2
    local -a _json_load_json_file_contents=()
    local -a _json_load_json_file_contents_tmp=()
    local -a _json_load_key_stack=()
    local _json_load_{value=,key=,ori_str=}
    local _json_load_line_{last_char=,cnt=,content=}
    local _json_load_leaf_set_key=''
    local -i _json_load_lev=0 _json_load_pop_cnt=0

    mapfile -t _json_load_json_file_contents_tmp < "$_json_load_json_input_file_path"
    for _json_load_line_content in "${_json_load_json_file_contents_tmp[@]}" ; do
        # 删除存空行和全是空白字符的行
        if [[ ! "$_json_load_line_content" =~ ^[[:space:]]*$ ]] ; then
            _json_load_json_file_contents+=("$_json_load_line_content")
        fi
    done

    # 每个孤键的类型由栈里面的最后一个元素决定
    _json_load_line_last_char="${_json_load_json_file_contents[0]: -1}"

    for((_json_load_line_cnt=1;_json_load_line_cnt<${#_json_load_json_file_contents[@]};)) ; do
        _json_load_lev=0
        _json_load_line_content="${_json_load_json_file_contents[_json_load_line_cnt]}"

        [[ "$_json_load_line_content" =~ ^(\ *) ]] && {
            _json_load_lev=${#BASH_REMATCH[1]}
            ((_json_load_lev/=4))
            ((_json_load_lev--))
        }

        if ((_json_load_lev<${#_json_load_key_stack[@]})) ; then
            # 先弹出多余的键
            ((_json_load_pop_cnt=${#_json_load_key_stack[@]}-_json_load_lev))
            _json_load_key_stack=("${_json_load_key_stack[@]::${#_json_load_key_stack[@]}-_json_load_pop_cnt}")
        fi

        _json_load_key="${_json_load_line_content#"${_json_load_line_content%%[! ]*}"}"
        # 判断最后一个字符是否是空格确定是否是叶子节点
        _json_load_line_last_char="${_json_load_line_content: -1}"

        if [[ ' ' == "$_json_load_line_last_char" ]] ; then
            # 先取key字符,和栈里面组合成的键一起设置数据结构
            _json_load_value="${_json_load_json_file_contents[_json_load_line_cnt+1]}"
            _json_load_value="${_json_load_value#"${_json_load_value%%[! ]*}"}"  

            # key和value都要从Q字符串转换成常规字符串(最后三个字符不能转,它们不属于Q字符串 ⇒ )
            eval "_json_load_ori_str=${_json_load_key:0:-3}"
            eval "_json_load_value=$_json_load_value"

            _json_load_leaf_set_key="${_json_load_key: -2:1}"


            if [[ "${_json_load_leaf_set_key}" == '⇒' ]] ; then
                _json_load_leaf_set_key="[${_json_load_ori_str}]"
            else
                _json_load_leaf_set_key="${_json_load_ori_str}"
            fi

            json_set '_json_load_json_out_ref' "${_json_load_key_stack[@]}" "${_json_load_leaf_set_key}" '' "$_json_load_value"

            ((_json_load_line_cnt+=2))
        else
            # key从Q字符串转换成常规字符串(最后两个字符不能转,它们不属于Q字符串 ⇒)
            eval "_json_load_ori_str=${_json_load_key:0:-2}"

            if [[ "${_json_load_key: -1}" == '⇒' ]] ; then
                _json_load_key_stack+=("[${_json_load_ori_str}]")
            else
                _json_load_key_stack+=("${_json_load_ori_str}")
            fi
            
            ((_json_load_line_cnt++))
        fi
    done
}

return 0
