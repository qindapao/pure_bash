. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_extend]++)) && return 0

# 一个字典合并到另外一个字典
# pc@DESKTOP-0MVRMOU ~                                                                                                                                         
# $ declare -A m=(x y z k)
# pc@DESKTOP-0MVRMOU ~                                                                                                                                         
# $ declare -p m
# declare -A m=([z]="k" [x]="y" )
# pc@DESKTOP-0MVRMOU ~                                                                                                                                         
# $ 
# 如上面所示，只有bash5.2才支持m=(x y z k)这样的定义关联数组的语法的
# 只能关联数组和关联数组相加,加数组是不行的
# pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# $ ay=('zy
# > 22' '12
# > kk')
# pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# $ declare -A ax=()
# pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# 这样是不行的
# $ ax+=("${ay[@]}")
# pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# $ declare -p ax
# declare -A ax=([$'zy\n22 12\nkk']="" )
# pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# $ declare -A ax=()
# pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# 这样也不行
# $ eval ax+=("${ay[@]}")
# pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# $ declare -p ax
# declare -A ax=([zy]="22" [12]="kk" )
# pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# $ declare -p ay
# declare -a ay=([0]=$'zy\n22' [1]=$'12\nkk')
# 但是直接相加的语法又是可以的
# pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# $ ax+=('zy
# > 22' '12
# > kk')
# pc@DESKTOP-0MVRMOU /cygdrive/e/code/pure_bash/test/cases/other                                                                                               
# $ declare -p ax
# declare -A ax=([$'zy\n22']=$'12\nkk' )
if ((__META_BASH_VERSION>=5002000)) ; then
    dict_extend ()
    {
        # 不能用小写的k操作符,但是在printf中可以用小写的k操作符
        # 注意这里需要两层展开
        eval "eval $1+=(\"\${$2[@]@K}\")"
    }
else
    # :TODO: 待测试
    dict_extend ()
    {
        local _dict_extend_script='
            local i'$1$2'
            for i'$1$2' in "${!'$2'[@]}"; do
              '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
            done'
        eval -- "$_dict_extend_script"
    }
fi

return 0

