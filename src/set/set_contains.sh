. ./meta/meta.sh
((DEFENSE_VARIABLES[set_contains]++)) && return 0

# 判断某元素是否在集合
# 1: 集合名
# 2: 元素键
set_contains () { eval "[[ \${$1[x\$2]+set} ]]" ; }

return 0

