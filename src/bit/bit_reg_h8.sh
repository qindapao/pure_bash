. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_reg_h8]++)) && return 0


# 使用方法
# xx=$(bit_reg_h8 0xaabb)
bit_reg_h8 () { printf "0x%x" $((($1>>8)&0xff)) ; }

return 0

