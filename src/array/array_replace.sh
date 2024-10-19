. ./meta/meta.sh
((DEFENSE_VARIABLES[array_replace]++)) && return 0


# eval 还是要尽量少用,因为会造成代码行数不准确
#
# 替换数组中的元素为新值,如果不提供新值,就删除相关元素,并不改变索引
# 1: 需要操作的数组或者关联数组名
# 2: 需要替换的元素值
# 3: 需要替换成的值(如果这个参数不存在就删除相关的值)
#
# 返回值:
#   0: 发生了替换或者删除
#   1: 并没有发生替换或者删除
array_replace ()
{
    local _array_replace_script$1='
    local iNAME=0 extNAME=1
    for iNAME in "${!NAME[@]}"; do
        [[ ${NAME[iNAME]} == "$2" ]] || continue
        extNAME=0
        if (($#>=3)); then
            NAME[iNAME]=$3
        else
            unset -v '\''NAME[iNAME]'\''
        fi
    done
    return "$extNAME"
    '
    eval -- eval -- '"${_array_replace_script'$1'//NAME/$1}"'
}

return 0

