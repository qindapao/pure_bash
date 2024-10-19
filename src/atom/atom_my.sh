. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_my]++)) && return 0

. ./log/log_dbg.sh || return 1

# 模拟perl5的获取参数方式(注意:一个函数中只能执行一次)
# multi local
alias 'ml'="eval 'declare"
# ml '{a,b,c,d}'=$1;shift;'
# 好像并没有太大的优势!!娱乐功能
# local a=$1 b=$2 c=$3 d=$4
# 但是可以这样(这样用于函数的变量前缀还行)
P='$1;shift;'
# ml head_'{a,b,c,d}=$P
# local head_a=$1 head_b=$2 head_c=$3 head_d=$4

return 0

