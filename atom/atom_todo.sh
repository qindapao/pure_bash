. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_todo]++)) && return 0


# :TODO: 可以给高阶函数传递多个数组函数，以及每个都可以正确带上自己的参数
# 诀窍是使用getopts,同一个字母的参数为一个函数的函数名或者参数
# 然后传递参数通过-a func_name1 -a 1 -a 2 -a 3 -b func_name2 -b 5 -b 5 -b 7这种方式区分不同函数的参数
# 可以弄一个公共的函数用于还原每个函数的参数即可
# my_func ()
# {
# 	local var
# 	local optind
# 	while getopts "a:b:c:" var ; do
# 		case "$var" in
# 			a)
# 				declare -p OPTIND
# 				declare -p OPTARG
# 				;;
# 			b)
# 				declare -p OPTIND
# 				declare -p OPTARG
# 				;;
# 			c)
# 				declare -p OPTIND
# 				declare -p OPTARG
# 				;;
# 		esac
# 	done
# }
# 
# mx=(-a "-b" -b "gege geg" -b "12345" -c "-c")
# 
# my_func "${mx[@]}"
# 
# 
# [root@localhost ~]# sh test.sh 
# declare -i OPTIND="3"
# declare -- OPTARG="-b"
# declare -i OPTIND="5"
# declare -- OPTARG="gege geg"
# declare -i OPTIND="7"
# declare -- OPTARG="12345"
# declare -i OPTIND="9"
# declare -- OPTARG="-c"
# [root@localhost ~]# 

return 0

