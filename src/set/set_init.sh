. ./meta/meta.sh
((DEFENSE_VARIABLES[set_init]++)) && return 0

# 集合的初始化,需要在外部定义一个关联数组
set_init ()
{
    eval -- ''$1'=()'
}

return 0

