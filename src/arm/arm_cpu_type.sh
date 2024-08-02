. ./meta/meta.sh
((DEFENSE_VARIABLES[arm_cpu_type]++)) && return 0

# 获取ARM CPU的型号的关键部分 bit4 ~ bit19
# 1: 需要保存到的变量名
arm_cpu_type ()
{
    local -i _arm_cpu_type=$(</sys/devices/system/cpu/cpu0/regs/identification/midr_el1)
    _arm_cpu_type=${_arm_cpu_type:-0}
    ((_arm_cpu_type=(_arm_cpu_type>>4)&0xffff))
    
    eval -- "$1=\$_arm_cpu_type"
}

return 0

