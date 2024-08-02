. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_bashopts]++)) && return 0

# 函数功能,保存shopt的默认参数,用于还原
# 参数说明
# 1: 需要保存bash选项值的选项
# 2: 选项需要保存到的变量名称(最好先声明为局部变量)
# 3: 需要进行的原始操作
#   -s 打开
#   -u 关闭
atom_bashopts ()
{
    eval -- "$2='-u'"
    eval -- "shopt -q $1 && $2='-s'"
    shopt "$3" "$1"
}

return 0

