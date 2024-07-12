# PCI相关的命令函数封装

. ./meta/meta.sh
((DEFENSE_VARIABLES[pci_check_off]++)) && return 0

# 检查某个pci总线已经被移除
# 返回: 查找不到某个总线 真
pci_check_off () { [[ "$(lspci)" != *"${1} "* ]] ; }

return 0

