# 所有操作依赖,比atom.sh更底层
((__META++)) && return 0

# 别名的使用要注意,如果作为参数传给高阶函数,要么需要在高阶函数中手动展开,常规使用会自动展开
# 并且高阶函数调用常规函数的时候不能加引号,不然如果别名带参数,会被当作整体处理



declare -gA DEFENSE_VARIABLES=([meta]=1 )
# 脚本中启用别名扩展(默认关闭)
shopt -s expand_aliases
# 为了安全起见删除所有的已知别名(防止意外行为)
unalias -a

# 在函数内部关闭shell的调试
# local -让选项变成局部,但是这里只能local -不能赋值
# local -=hB这种写法是错误的
# 目前验证了这种语法在bash4.4.23(1)上是支持的
alias disable_xv='local - ; set +xv'

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
    local part1= part2= part3=
    if [[ "$BASH_VERSION" =~ ([0-9]+)\.([0-9]+).([0-9]+) ]]; then
        # 这和使用引用变量是一个效果
        # 5000017
        part1="${BASH_REMATCH[1]}" ; part2="${BASH_REMATCH[2]}" ; part3="${BASH_REMATCH[3]}"
        printf -v "$1" "%s%03d%03d" "${part1}" "$((10#$part2))" "$((10#$part3))"
    fi
}

meta_get_bash_version __META_BASH_VERSION



return 0

