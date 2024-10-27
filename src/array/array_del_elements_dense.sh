. ./meta/meta.sh
((DEFENSE_VARIABLES[array_del_elements_dense]++)) && return 0

. ./cntr/cntr_grep_wp.sh || return 1

# 不保留索引,删除后的数组是一个致密数组(稀疏输入进来,也转换成致密数组)
# 1: 需要处理的数组引用
# 2~@: 需要删除的元素的值
array_del_elements_dense ()
{
    set -- "${@:2}" "$1"
    while (($#-1)) ; do
        eval cntr_grep_wp "\$$#" ''\''[[ $1 != "$4" ]]'\''' '"$1"'
        shift
    done
}

return 0

