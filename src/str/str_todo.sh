# 字符串操作集合(模拟perl5的行为)
# 注意:命令行参数大小限制,数组参数不能过大
# 为了保证引用变量不会重名,所有带引用变量的函数中的局部变量都带函数名字,不带引用变量的函数不受影响
# 如果不需要改变原数组,可以使用下面的方式获取数组内容
# array::merge() {
#     [[ $# -ne 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
#     declare -a arr1=("${!1}")
#     declare -a arr2=("${!2}")
#     declare out=("${arr1[@]}" "${arr2[@]}")
#     printf "%s\n" "${out[@]}"
# }
#
# 有一种临时保存变量的好方法，可以利用declare -p 把需要保存的变量打印到一个临时文件中
# 当需要还原变量的时候，直接source ./tmp_file 就可以在当前环境下加载这些变量

# :TODO: 根据业务需求来实现封装,尽量使纯bash实现

# :TODO: https://github.com/vlisivka/bash-modules/blob/master/bash-modules/src/bash-modules/string.sh
# 这里有一些有用的函数，空了可以整理下

. ./meta/meta.sh
((DEFENSE_VARIABLES[str_todo]++)) && return 0

# 可以在函数中使用local修改全局IFS的值，退出函数后，值被还原，只在函数内生效
# 可以避免对全局IFS的变更
# test_1 ()
# {
# 	local IFS=':'
# 	read -r xx yy zz <<< "1:2:3"
# 	echo $xx
# 	echo $yy
# 	echo $zz
# }
# 
# test_1
# 
# read -r xx yy zz <<< "1 2 3"
# echo $xx
# echo $yy
# echo $zz

return 0

