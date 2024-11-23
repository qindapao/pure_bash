. ./meta/meta.sh
((DEFENSE_VARIABLES[arm_cpu_type]++)) && return 0

# 获取ARM CPU的型号的关键部分 bit4 ~ bit19
# 1: 需要保存到的变量名
arm_cpu_type ()
{
    eval -- '
    local -i _arm_cpu_type'$1'=$(</sys/devices/system/cpu/cpu0/regs/identification/midr_el1)
    _arm_cpu_type'$1'=${_arm_cpu_type'$1':-0}
    ((_arm_cpu_type'$1'=(_arm_cpu_type'$1'>>4)&0xffff))
    
    '$1'=$_arm_cpu_type'$1'
    '
}

return 0

