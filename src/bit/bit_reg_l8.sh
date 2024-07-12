. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_reg_l8]++)) && return 0


# 使用方法
# xx=$(bit_reg_l8 0xaabb)
bit_reg_l8 () { printf "0x%x" $(($1&0xff)) ; }

return 0

