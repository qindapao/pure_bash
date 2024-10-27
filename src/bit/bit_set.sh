. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_set]++)) && return 0


# :TODO: bit_set_value bit_set_conti_bits_value 可以考虑用
# 下面更好的实现来替代
# 设置一系列bit位的值
# 1: 设置设置位的变量的名字
# 2: 需要设置的位
# 3: 位设置的值(0/1)
# ...: 其他组
bit_set () 
{ 
    set -- "${@:2}" "$1"
    while (($#-1)) ; do
        eval -- "((\${$#}=(\$2==0)?\${$#}&~(1<<\$1):\${$#}|(1<<\$1)))"
        shift 2
    done
}

return 0

