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


# :TODO: 当前的字符串函数如果要输出结果是通过printf值的方式执行，并且和高阶map函数
# 配合也是这种方式，后续如果想效率高,可以采用应用方式，被引用的变量名字可以好好设计
# 同时高阶函数也需要调整,比如重组数组不是使用变量替换的方式$(),而是获取某个约定的变量的
# 值，约定的变量名可以和函数名关联起来等等... ...

# :TODO: https://github.com/vlisivka/bash-modules/blob/master/bash-modules/src/bash-modules/string.sh
# 这里有一些有用的函数，空了可以整理下

. ./meta/meta.sh
((DEFENSE_VARIABLES[str_todo]++)) && return 0

# 如果一个函数返回一个数组,可以使用下面的方式取数组中的值,就像元组拆包一样
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/str# declare -p xa
# declare -a xa=([0]="a 1" [1]="b 2" [2]="c 3")
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/str# i=0
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/str# eval {x1,x2,x3}=\"${xa[i++]}\"
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/str# declare -p x1 x2 x3
# declare -- x1="a 1"
# declare -- x2="b 2"
# declare -- x3="c 3"
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/str# 

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

