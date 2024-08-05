. ./meta/meta.sh
((DEFENSE_VARIABLES[set_union]++)) && return 0

. ./dict/dict_extend.sh || return 1
. ./atom/atom_func_reverse_params.sh || return 1

# 求若干个集合的并集
# @:  并集的所有集合的变量名列表
# $#: 并集保存集合的变量名
#
# 返回值:
#   0: 返回正常
#   1: 某个数据结果并不是关联数组
#   shopt -s extdebug
#   BASH_ARGV 反向存储当前函数参数
#   但是这里用了更巧妙的方法实现



set_union ()
{
    # 翻转函数的参数
    atom_func_reverse_params
    while(($#-1)) ; do
        eval -- "dict_extend \"\${$#}\" \"\$1\"" 
        shift
    done

    return 0
}

return 0

