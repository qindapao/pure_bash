. ./meta/meta.sh
((DEFENSE_VARIABLES[nfor.ndo.ndone]++)) && return 0


# 只以空格作为分隔符的for循环变体,并且进入循环后马上还原IFS(防止影响for循环内部的代码),
# 或者退出循环也还原(循环并没有进入)
# 使用效果如下
# 注意这里的$a不能用引号引起来,所以用来迭代安全Q字符串才安全(没有异常的扩展和保证最后是真正换行结束)
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/try# nfor i in $a ; ndo echo $i; ndone
# 1 2 3
# 4 6
# 6 9 0
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/try# for i in $a ; do echo $i; done
# 1
# 2
# 3
# 4
# 6
# 6
# 9
# 0
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/try# declare -p a
# declare -- a="
# 1 2 3
# 4 6
# 6 9 0"
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/try# 

alias nfor="declare OLD_IFS=\"\$IFS\" ; declare IFS=\$'\n' ; for"
alias ndo="do IFS=\"\$OLD_IFS\" ;"
alias ndone="done ; IFS=\"\$OLD_IFS\" ;"

return 0

