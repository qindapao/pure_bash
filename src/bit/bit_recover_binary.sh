. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_recover_binary]++)) && return 0

# 从一个16进制字符串变量中还原一个二进制文件
# 1 保存二进制数据的字符串值
# 2 输出文件路径
bit_recover_binary () { printf "$1" > "$2" ; }

return 0

