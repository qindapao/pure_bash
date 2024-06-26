# 所有操作依赖,比atom.sh更底层


((__META++)) && return 0

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

return 0

