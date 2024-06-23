# 所有操作依赖,比atom.sh更底层


((__META++)) && return 0

declare -gA DEFENSE_VARIABLES=([meta]=1 )
# 脚本中启用别名扩展(默认关闭)
shopt -s expand_aliases

# :TODO: 其它库的粒度可以进一步缩小,节省业务脚本的内存消耗
# 比如数组操作就可以分成几个库
# 所有的函数都禁止循环引用:
# 比如 A->B->C->A, 如果形成一个环是不行的,尽量不要这样递归调用

return 0

