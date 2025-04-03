. ./meta/meta.sh
((DEFENSE_VARIABLES[json_load]++)) && return 0

. ./str/str_trim.sh || return 1
. ./json/json_common.sh || return 1
. ./json/json_set.sh || return 1
. ./json/json_overlay.sh || return 1
. ./json/json_awk_load.sh || return 1
. ./json/json_set_params_del_bracket.sh || return 1
. ./json/json_pack.sh || return 1
. ./json/json_balance_load.sh || return 1
. ./json/json_normal_load.sh || return 1
. ./regex/regex_common.sh || return 1
. ./cntr/cntr_copy.sh || return 1
. ./cntr/cntr_extend.sh || return 1
. ./array/array_qsort.sh || return 1
. ./str/str_ltrim_zeros.sh || return 1

# . ./log/log_dbg.sh || return 1

# 实现应该比现在更加简单的,因为键的路径是明确的啊
# 直接调用json_set 或者json_overlay 函数就行了,都不用先转换成树状结构
# 这样在没有python3但是有awk的环境下就能使用
# 如果是busybox的环境,JSON.awk的官网说了,可以打补丁解决
# 让json_common_load.py成为可选,而不是必须存在的模块


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
# :TODO: 无法支持json中的null对象,只能暂时当作字符串处理
json_load ()
{
    # 变量的数据类型必须外面定义
    local -n _json_load_json_out_ref=$1

    local _json_load_json_input_file_path=$2
    # 如果是 balance 算法适合于平衡的json normal算法适合完全失衡json
    # 大部分情况下balance算法优先
    local _json_load_json_load_algorithm=${3:-'balance'}
    # 如果还有后面的参数表示只加载某个键后面对应的json

    # 判断一个字符串是一个标准的json字符串
    local _json_load_json_str=$(<${_json_load_json_input_file_path})
    str_trim _json_load_json_str

    if [[ "${_json_load_json_str:0:1}" == '{' ]] ; then
        case "$JSON_COMMON_STANDARD_JSON_PARSER" in
        python3)
            json_common_load.py -a "$JSON_COMMON_SERIALIZATION_ALGORITHM" \
                                -s "$JSON_COMMON_MAGIC_STR" \
                                -m 'standard_to_bash' \
                                -i "${_json_load_json_input_file_path}" \
                                -o "${_json_load_json_input_file_path%.*}_bash.txt" \
                                -- "${@:4}"
            _json_load_json_input_file_path="${_json_load_json_input_file_path%.*}_bash.txt"
            ;;
        awk)
            json_awk_load _json_load_json_out_ref "$_json_load_json_input_file_path" "$_json_load_json_load_algorithm" "${@:4}"
            return $?
            ;;
        *)
            return ${JSON_COMMON_ERR_DEFINE[load_unknown_parser]}
            ;;
        esac
    fi

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
        if [[ ! "$_json_load_line_content" =~ $REGEX_COMMON_BLANK_LINE ]] ; then
            _json_load_json_file_contents+=("$_json_load_line_content")
        fi
    done

    ((${#_json_load_json_file_contents_tmp[@]}==2)) && {
        # 如果获取到的就是字符串,直接赋值即可
        eval -- "_json_load_json_out_ref=${_json_load_json_file_contents_tmp[1]}"
        return ${JSON_COMMON_ERR_DEFINE[ok]} 
    }

    _json_load_json_out_ref=()

    # 每个孤键的类型由栈里面的最后一个元素决定
    _json_load_line_last_char="${_json_load_json_file_contents[0]: -1}"

    # 定义一个二维数组,用于存放所有的键和值(最后一个值前面是键)
    local -a _json_load_key_values=()
    # 二维数组中的每个元素
    local -a _json_load_key_value_line=()
    local _json_load_sort_num

    for((_json_load_line_cnt=1;_json_load_line_cnt<${#_json_load_json_file_contents[@]};)) ; do
        _json_load_lev=0
        _json_load_line_content="${_json_load_json_file_contents[_json_load_line_cnt]}"

        [[ "$_json_load_line_content" =~ $REGEX_COMMON_SPACE_LINE_CONTENT ]] && {
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
        local -i _json_load_space_num=0
        if [[ "$_json_load_key" =~ ([>=])([[:space:]]*)$ ]] ; then
            _json_load_space_num=${#BASH_REMATCH[2]}
            _json_load_leaf_set_key=${BASH_REMATCH[1]}
        fi

        # key和value都要从Q字符串转换成常规字符串(最后3~5个字符不能转,它们不属于Q字符串 > )
        eval "_json_load_ori_str=${_json_load_key:0:-2-_json_load_space_num}"
        if ((_json_load_space_num)) ; then
            if [[ "${_json_load_leaf_set_key}" == '>' ]] ; then
                _json_load_leaf_set_key="[${_json_load_ori_str}]"
            else
                _json_load_leaf_set_key="${_json_load_ori_str}"
            fi

            # 如果是字符串用设置值的方式,如果是空数组或者空字典,overlay进去即可
            # :TODO: 字符串节点和null节点一起处理的,可能不严谨
            if ((_json_load_space_num<3)) ; then
                # 先取key字符,和栈里面组合成的键一起设置数据结构
                _json_load_value="${_json_load_json_file_contents[_json_load_line_cnt+1]}"
                _json_load_value="${_json_load_value#"${_json_load_value%%[! ]*}"}"  
                eval "_json_load_value=$_json_load_value"
            elif ((_json_load_space_num==3)) ; then
                ((JSON_COMMON_SERIALIZATION_ALGORITHM==JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin])) && {
                    _json_load_value="declare -a ${JSON_COMMON_MAGIC_STR}1=()" ; } || {
                    _json_load_value="declare -a ${JSON_COMMON_MAGIC_STR}1=${JSON_COMMON_NULL_ARRAY_BASE64}" ;}
            else
                ((JSON_COMMON_SERIALIZATION_ALGORITHM==JSON_COMMON_SERIALIZATION_ALGORITHM_ENUM[builtin])) && {
                    _json_load_value="declare -A ${JSON_COMMON_MAGIC_STR}1=()" ; } || {
                    _json_load_value="declare -A ${JSON_COMMON_MAGIC_STR}1=${JSON_COMMON_NULL_ARRAY_BASE64}" ; }
            fi

            # json_set '_json_load_json_out_ref' "${_json_load_key_stack[@]}" "${_json_load_leaf_set_key}" '' "$_json_load_value"
            printf -v _json_load_sort_num "%03d" $((${#_json_load_key_stack[@]}+1))
            _json_load_key_value_line=("$_json_load_sort_num" "${_json_load_key_stack[@]}" "${_json_load_leaf_set_key}" "" "$_json_load_value")
            _json_load_key_values+=("${_json_load_key_value_line[*]@Q}")

            ((_json_load_line_cnt+=2))
        else
            if [[ "${_json_load_key: -1}" == '>' ]] ; then
                _json_load_key_stack+=("[${_json_load_ori_str}]")
            else
                _json_load_key_stack+=("${_json_load_ori_str}")
            fi
            
            ((_json_load_line_cnt++))
        fi
    done

    # normal or balance
    json_${_json_load_json_load_algorithm}_load _json_load_key_values _json_load_json_out_ref
}

return 0

