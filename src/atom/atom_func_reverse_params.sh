. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_func_reverse_params]++)) && return 0

# 下面这个别名的作用是翻转函数的参数列表
alias atom_func_reverse_params='eval eval set -- "\\\"$\{{$#..1}\}\\\""'

return 0

