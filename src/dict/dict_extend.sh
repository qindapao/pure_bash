dict_extend.sh

. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_extend]++)) && return 0

. ./atom/atom_is_varname_valid.sh || return 1

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
        atom_is_varname_valid "$1" "$2" || return 1
        eval "eval $1+=(\"\${$2[@]@K}\")"
        true
    }
else
    # :TODO: 待测试
    dict_extend ()
    {
        atom_is_varname_valid "$1" "$2" || return 1
        local _dict_extend_script_i${1}${2}='
            local i'$1$2'
            # ldebug_p "we are here"
            for i'$1$2' in "${!'$2'[@]}"; do
                '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
            done'
        # 用eval执行代码的一个问题是会造成日志中打印的行号不准,要自己根据偏移计算下,但是不会影响其它部分的代码的行号计算
        eval -- eval -- \"\$"_dict_extend_script_i${1}${2}"\"
        true

        # lwarn_p "we are ohter line"
        # lerror_p "we are ohter line2"
        # [d ./dict/dict_extend.sh dict_extend(67):test_case1(37):main(41) 2024-07-10T15:08:42] we are here 
        # ----------------------------------------------------------------------------------
        # [d ./dict/dict_extend.sh dict_extend(67):test_case1(37):main(41) 2024-07-10T15:08:42] we are ohter line 
        # ----------------------------------------------------------------------------------
        # [d ./dict/dict_extend.sh dict_extend(68):test_case1(37):main(41) 2024-07-10T15:08:42] we are ohter line2 
        # ----------------------------------------------------------------------------------
        # declare -A m=([$'zy\n    xk\n    122']=$'geg\n    gege' [$'45g \n    geg\n    ']=$'gge\n    gege\n    123' )
        # root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/other# 
    }
fi

return 0

