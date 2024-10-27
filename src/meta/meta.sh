# Copyright (c) 
# 作者: qindapao northisland2017@gmail.com
# 当前库只能适用于bash4.4或者以上版本,低于bash4.4某些语法不兼容

# 所有操作依赖,比atom.sh更底层
((__META++)) && return 0

# 主版本号.次版本号.补丁版本号.发布日志
PURE_BASH_LIB_VERSION='1.0.0.2024.10.26'

meta_get_lib_version ()
{
    case "$#" in
    0)
    printf "%s" "$PURE_BASH_LIB_VERSION"
    ;;
    *)
    printf -v "$1" "%s" "$PURE_BASH_LIB_VERSION"
    ;;
    esac
}

# 别名的使用要注意,如果作为参数传给高阶函数,要么需要在高阶函数中手动展开,常规使用会自动展开
# 并且高阶函数调用常规函数的时候不能加引号,不然如果别名带参数,会被当作整体处理

# 默认关闭调试
set +vx
# 关闭历史命令扩展
set +H

declare -gA DEFENSE_VARIABLES=([meta]=1 )

# 检查当前环境中的bash选项是否正常(正常情况下只需要hB两个选项,交互式shell会更多)
# h: 命令历史记录功能
# B: 启用大括号扩展
# 强制打开防止意外行为
set -hB

# 脚本中启用别名扩展(默认关闭)
shopt -s expand_aliases
# 默认打开量词扩展
shopt -s extglob
# 为了安全起见删除所有的已知别名(防止意外行为)
unalias -a

# 在函数内部关闭shell的调试
# local -让选项变成局部,但是这里只能local -不能赋值
# local -=hB这种写法是错误的
# 目前验证了这种语法在bash4.4.23(1)上是支持的
alias disable_xv='local - ; set +xv'

# :TODO: LC_COLLATE=C
#           强制使用C语言环境的字符排序规则，从而确保 [a-z] 和 [A-Z] 按预期工作
#       globasciiranges
#           bash5.2引入了这个，不会有匹配问题
#       locale
#           命令查看和所有环境变量相关
#
# :TODO: 给函数传递多个数组的方法
# -a1 xx -a1 yy -a1 zz -a2 kk -a2 uu ... ...
# :TODO: 使用这种方式甚至可以传递关联数组,其实最简单的还是直接传递名字
# 在函数中使用引用或者eval即可

# :TODO: 其它库的粒度可以进一步缩小,节省业务脚本的内存消耗
# 比如数组操作就可以分成几个库
# 所有的函数都禁止循环引用:
# 比如 A->B->C->A, 如果形成一个环是不行的,尽量不要这样递归调用
# 申明的所有变量都必须赋初值,以防止declare -p打印不符合预期
# Storage:~ # unset a
# Storage:~ # declare -p a
# -bash: declare: a: not found
# Storage:~ # declare a
# Storage:~ # declare -p a
# declare -- a
# Storage:~ # echo ${a[@]@A}
# 
# Storage:~ # 
# 另外不要在函数中unset一个和外部全局变量同名的局部变量，同样会造成declare -p 打印
# 不符合预期（`declare -- a`变量后面没有等号。）
#
# 一般情况下也不需要显示的取消一个变量。除非在数组中的子元素用得比较多。

# 在bash4.2中引入了BASH_VERSINFO环境变量,是一个只读的关联数组,但是由于在低版本中无法使用,所以不用它
# declare -ar BASH_VERSINFO=([0]="5" [1]="0" [2]="17" [3]="1" [4]="release" [5]="x86_64-pc-linux-gnu")
meta_get_bash_version ()
{
    # 1: 主版本号
    # 2: 次版本号
    if [[ "$BASH_VERSION" =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
        # 这和使用引用变量是一个效果
        # 5000017
        printf -v "$1" "%s%03d%03d" "${BASH_REMATCH[1]}" "$((10#${BASH_REMATCH[2]}))" "$((10#${BASH_REMATCH[3]}))"
    fi
}

meta_get_bash_version __META_BASH_VERSION
if ((__META_BASH_VERSION<4004000)) ; then
    echo "The bash version must be 4.4 or later!" >&2
    return 1
fi

declare -g PURE_STDIN='/dev/stdin'
# :TODO: 具体部署的时候这里要改变
# ibase64 工具的部署也放到统一的目录来
case "$(uname -a)" in
*[xX]86_64\ [cC][yY][gG][wW][iI][nN]*)
    declare -g PURE_BASH_TOOLS_DIR='/cygdrive/d/my_code/pure_bash/src/tools' ;;
*)  declare -g PURE_BASH_TOOLS_DIR='/mnt/d/my_code/pure_bash/src/tools' ;;
esac

# 变量赋值为空
meta_var_clear ()
{
    while(($#)) ; do
        eval -- '
        case "${'$1'@a}" in
        *[aA]*) '$1'=() ;;
            *)  '$1'="" ;;
        esac
        '
        shift
    done
}

# 空数组对象
declare -ga PURE_BASH_NULL_ARRAY=()
# 空字典对象
declare -gA PURE_BASH_NULL_DICT=()


return 0

