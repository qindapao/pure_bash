# 所有操作依赖,比atom.sh更底层


((__META++)) && return 

declare -gA DEFENSE_VARIABLES=([meta]=1 )

# :TODO: 其它库的粒度可以进一步缩小,节省业务脚本的内存消耗
# 比如数组操作就可以分成几个库
# 所有的函数都禁止循环引用:
# 比如 A->B->C->A, 如果形成一个环是不行的,尽量不要这样递归调用

return 0

