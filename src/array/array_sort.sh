. ./meta/meta.sh
((DEFENSE_VARIABLES[array_sort]++)) && return 0

. ./cntr/cntr_map.sh || return 1
. ./str/str_split.sh || return 1

# :TODO: 当前的素值排序只支持整形并不支持浮点数,如果要支持浮点数函数的性能会大幅降低
# :TODO: 为了支持稳定排序(多域段优先级排序),当前的函数和后面需要实现的qsort函数需要支持
# 只排序指定的索引功能(前一个域段索引相同的部分,由稳定排序函数输出,当前函数和qsort函数支持参数传递)


# :TODO: 在另外一个文件中实现快速排序算法
# :TODO: 需要在另外的地方实现稳定排序
# 在Python中，我们可以使用lambda函数和sort()或sorted()函数来对二维数组进行排序。
# lambda函数可以定义排序的规则。在你的例子中，规则是优先按照数组的第一个元素排序，
# 然后按照第二个元素排序，最后按照第三个元素排序。这种排序方法被称为稳定排序，
# 因为当两个元素相等时，它们的原始顺序会被保留。

# 这是一个实现这种排序的Python代码示例：
# 
# Python
# 
# arr = [[10,7,5], [8,9,4], [11,2,6], [4,1,7]]
# arr.sort(key=lambda x: (x[0], x[1], x[2]))
# print(arr)
# 运行这段代码后，你会得到以下排序后的数组：
# 
# Python
# 
# [[4, 1, 7], [8, 9, 4], [10, 7, 5], [11, 2, 6]]
# AI 生成的代码。仔细查看和使用。 有关常见问题解答的详细信息.
# 这个数组首先按照第一个元素排序，然后在第一个元素相同的情况下，按照第二个元素排序，最后在前两个元素都相同的情况下，按照第三个元素排序。这就是这个问题的基本思想。希望这个答案对你有所帮助！

# declare -a key_array
#     local key_tmp
#     while IFS=$'\n' read -r key_tmp ; do
#         key_array+=("$key_tmp")
#     done < <(printf "%s\n" "${!slot_to_lines[@]}" | sort -t- -k1,1n -k2,2n)

# 可以指定不同的排序选项来按照特定的规则对文本进行排序。sort -t- -k1,1n -k2,2n 部分是用于排序的选项。

# 让我解释一下这些选项的含义：

# -t-：这表示使用 - 作为字段分隔符。在你的代码中，你的输入数据中的字段是用 - 分隔的。
# -k1,1n：这表示按照第一个字段（从左到右数）进行排序，并且使用数值排序（n 表示数值排序）。这将确保按照第一个字段的数值顺序进行排序。
# -k2,2n：这表示按照第二个字段进行排序，同样使用数值排序。这将在第一个字段相同时，按照第二个字段的数值顺序进行排序。
# 因此，整个命令 sort -t- -k1,1n -k2,2n 将根据第一个字段和第二个字段的数值顺序对数据进行排序。
# 这个命令也是实现了稳定排序，需要转换成bash脚本的内部实现。




# 排序一个数组中的元素(只能用于普通数组),关联数组没有顺序无法排序
# 规则:默认按照字典序排序
# 算法:当前使用冒泡排序算法
# 1: 需要排序数组引用名
_array_sort ()
{
    local -n __array_sort_ref_arr=$1
    local __array_sort_{mark="$2",delimiter="$3",field="$4"}
    declare -a __array_sort_arr_indexs=("${!__array_sort_ref_arr[@]}")
    ((${#__array_sort_arr_indexs[@]})) || return 

    local -a __array_sort_tmp_arr=("${__array_sort_ref_arr[@]}")
    local -a __array_sort_tmp_arr_filed=("${__array_sort_ref_arr[@]}")

    # 如果有分隔符和域段,那么取它们作为子数组来排序
    if [[ -n "$__array_sort_delimiter" && -n "$__array_sort_field" ]] ; then
        # 后面是完整的参数不能拆行
        # cntr_map __array_sort_tmp_arr_filed \
        #     "eval \$1[\\\$2]=\$(str_split_s \"\${3}\" \"$__array_sort_delimiter\" \"$__array_sort_field\")"
        # 现在可以以下面这种更高效可读的方式来拆分
        cntr_map __array_sort_tmp_arr_filed str_split_a "$__array_sort_delimiter" "$__array_sort_field"
    fi

    local -i __array_sort_tmp_arr_size=${#__array_sort_tmp_arr[@]}

    local -i __array_sort_i __array_sort_j
    local __array_sort_tmp __array_sort_field_tmp

    for ((__array_sort_i = 0; __array_sort_i < __array_sort_tmp_arr_size; __array_sort_i++)); do
        for ((__array_sort_j = 0; __array_sort_j < __array_sort_tmp_arr_size-$__array_sort_i-1; __array_sort_j++)); do
            # 比较变量的展开必须在第二步进行,所以\$,符号变量在第一步展开,但是用单引号就可以不加\
            # 两种语法效果一样
            # if eval [[ '"${__array_sort_tmp_arr_filed[__array_sort_j]}"' "${__array_sort_mark}" '"${__array_sort_tmp_arr_filed[__array_sort_j+1]}"' ]] ; then
            if eval [[ "\"\${__array_sort_tmp_arr_filed[__array_sort_j]}\"" "${__array_sort_mark}" "\"\${__array_sort_tmp_arr_filed[__array_sort_j+1]}\"" ]] ; then
                # filed 数组一样需要更新
                __array_sort_field_tmp="${__array_sort_tmp_arr_filed[__array_sort_j]}"
                __array_sort_tmp_arr_filed[__array_sort_j]="${__array_sort_tmp_arr_filed[__array_sort_j+1]}"
                __array_sort_tmp_arr_filed[__array_sort_j+1]="$__array_sort_field_tmp"
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
    local -n _array_sort_ref_arr=$1
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

return 0

