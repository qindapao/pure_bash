# 所有操作依赖,比atom.sh更底层


((__META++)) && return 

declare -gA DEFENSE_VARIABLES=([meta]=1 )

# :TODO: 其它库的粒度可以进一步缩小,节省业务脚本的内存消耗
# 比如数组操作就可以分成几个库
# :TODO: 所有的注释都写成英文

