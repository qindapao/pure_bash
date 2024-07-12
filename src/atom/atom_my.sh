. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_my]++)) && return 0

. ./log/log_dbg.sh || return 1

# 模拟perl5的获取参数方式(注意:一个函数中只能执行一次)
# multi local
alias my='declare -i i=1;eval declare'
# 定义参数的同时打印入参值和个数
# :TODO: 这里设计可能不太好,因为这里调用了log_dbg函数,外部用户并不知道
alias myp='ldebug_p "($#) ${*}";declare -i i=1;eval declare'
# 继续赋值剩余元素为数组(注意:一个函数中只能执行一次)
alias mya='shift $((i-1));declare -a'
# 使用方法
# 这里赋值不需要用双引号保护(只有位置参数有效),并且这里大括号是必须保留的
# 如果参数不超过10个就不用大括号,为了保险可以都加上
# my {in_str,index,prefix,is_ignore_case}=\${$((i++))}

return 0

