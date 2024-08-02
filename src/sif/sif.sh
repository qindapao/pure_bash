. ./meta/meta.sh
((DEFENSE_VARIABLES[sif.selif.selse.sfi]++)) && return 0

# elif 语句的最大深度限制问题
# https://stackoverflow.com/questions/38662506/bash-script-size-limitation
# 一般情况下并不会遇到
# 解析器堆栈深度的限制，其作用是限制某些构造的复杂性。具体来说，它将语句elif中的
# 子句数量限制在 2500 个左右(elif数量不能超过2495个)
# 一般情况下不需要这么写
# while :; do
#   if condition1; then
#     # do something
#   break; fi; if condition2; then
#     # do something
#   break; fi; if condition3; then
#     # do something
#   break; fi; if condition4; then
#     # do something
#   break; fi
#   # No alternative succeeded
#   break
# done

alias sif='while true; do if'
alias selif='break; fi; if '
alias selse='break; fi'
alias sfi='break ;done' 

return 0

