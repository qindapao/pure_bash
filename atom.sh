# 原子操作集合(理论上当前文件不应该引用任何其它文件)
# 注意:命令行参数大小限制,数组参数不能过大

# :TODO: 根据业务需求来实现封装,尽量使纯bash实现
. ./meta.sh
((DEFENSE_VARIABLES[atom]++)) && return


# 在函数内部定义一个函数，在外面也是能看到的,所以要定义到外层函数的最上面
# :TODO: 简单的操作不一定要使用函数来定义，也可以使用alis别名(使用这个甚至可以创建自己的类型,由于意思不大,暂时不考虑)
# 但是别名无法接受参数,只是命令的简单替换,可以理解为固定宏,连函数宏的功能都没有

# set -u 选项不要设置，否则遇到使用未定义的变量会被退出([ -n "${DEBUG:-}" ] 所以很多项目中使用类似这种语法来保护)
#                    _______________  _______________
#                  .'               .'               .|
#                .'               .'               .' |
#              .'_______________.'______________ .'   |
#              | ___ _____ ___ || ___ _____ ___ |     |
#              ||_=_|__=__|_=_||||_=_|__=__|_=_||     |
#        ______||_____===_____||||_____===_____||     | __________
#     .'       ||_____===_____||||_____===_____||    .'          .'|
#   .'         ||_____===_____||||_____===_____||  .'          .'  |
# .'___________|_______________||_______________|.'__________.'    |
# |.----------.|.-----___-----.||.-----___-----.||    |_____.----------.
# |]          |||_____________||||_____________|||  .'      [          |
# ||          ||.-----___-----.||.-----___-----.||.'        |          |
# ||          |||_____________||||_____________|||==========|          |
# ||          ||.-----___-----.||.-----___-----.||    |_____|          |
# |]         o|||_____________||||_____________|||  .'      [        'o|
# ||          ||.-----___-----.||.-----___-----.||.'        |          |
# ||          |||             ||||_____________|||==========|          |
# ||          |||             |||.-----___-----.||    |_____|          |
# |]          |||             ||||             |||  .'      [          |
# ||__________|||_____________||||_____________|||.'________|__________|
# ''----------'''------------------------------'''----------''
#             (o)LGB                           (o)
# 

# 判断数据类型(不能判断一个数据是否是引用变量)
# i: 整数
# s: 字符串
# a: 数组
# A: 关联数组
atom_identify_data_type ()
{
    local -n _atom_identify_data_type_var_name="${1}"
    local _atom_identify_data_type_verify_type="${2}"
    local up_var_name=
    local real_var_name=

    local attribute=${_atom_identify_data_type_var_name@a}

    if [[ "$attribute" == *"$_atom_identify_data_type_verify_type"* ]] ; then
        return 0
    elif [[ -z "$attribute" ]] && [[ "s" == "$_atom_identify_data_type_verify_type" ]] ; then
        return 0
    fi
    
    return 1
}

atom_get_bash_version ()
{
    # 1: 主版本号
    # 2: 次版本号
    if [[ "$BASH_VERSION" =~ ([0-9]+)\.([0-9]+) ]]; then
        # 这和使用引用变量是一个效果
        printf -v "$1" "%s" "${BASH_REMATCH[1]}"
        printf -v "$2" "%s" "${BASH_REMATCH[2]}"
    fi
}

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

