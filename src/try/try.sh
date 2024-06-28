. ./meta/meta.sh
((DEFENSE_VARIABLES[try.catch.finally]++)) && return 0

. ./trap/trap_set.sh || return 1

# 加declare可以嵌套作用域
# https://github.com/niieani/bash-oo-framework/blob/master/lib/util/tryCatch.sh

# :TODO: catch中捕捉的错误类型是否可以定义下?
#       发生错误的时候，可以获取错误文件中的内容，然后可以读取各个错误码和错误消息，
#       然后就可以分别catch处理
# try别名执行的条件必须IS_ALLOW_TRAP_SET=1
# 如果不希望陷阱传播到函数和子shell,那么手动设置set +E(在最开始的地方设置)
# set +E
#
# try {
#     echo "3" | grep '1'    
# } catch {
#     printf "%s" "$(<$TRY_RESTORE_FILE)"
# }

# :TODO: 如何模拟函数抛出异常?
# :TODO: 后续甚至可以针对不同的错误类型分别处理,弄多个catch块,并且里面放置错误类型
# 错误类型的解析可以在生成的错误临时文件中进行,通过保存Q字符串,保证没有多余换行符,并且精确解析错误码,甚至错误字符串(最后一个命令也可以打印出来)
# 那么所有的函数的错误码设计就要讲究点了!
# 一个好的设计是如果函数有错误发生，那么应该往标准错误里面输出东西(不过具体还是要按情况定)
# try和catch必须配套使用
# 别名值的最后一个字符不要是空白字符(如果是空白字符比如空格比较危险,因为可能会继续扩展命令后面的别名)
# 这次declare ; rm 不会被再次扩展, 没有declare 和 rm的别名，然后 ; 不是规范的别名名
alias try='declare _try_restore_old_trap_err_file="$TRAP_ERR_FILE" ; declare _try_return_code=0 ; declare _try_have_err_trap=0 ; [[ "$(trap -p)" != *ERR* ]] && eval $(trap_set 1 ERR) ; TRAP_ERR_FILE=$(mktemp) ; declare TRY_RESTORE_FILE="$TRAP_ERR_FILE" ;'
# :TODO: 目前的情况是只要使用try catch 并且关闭set +E,后续陷阱中如果想开,手动开即可
alias catch='; [[ -s "$TRAP_ERR_FILE" ]] && _try_return_code=1 ; TRAP_ERR_FILE="$_try_restore_old_trap_err_file" ; ((_try_return_code)) &&'
alias finally='rm -f "$TRY_RESTORE_FILE" ;'

# !警告: 复杂别名中的`;`分隔的每个语句都要小心不要被别名再次扩展。尽量不要弄嵌套的复杂别名。


return 0

