. ./meta/meta.sh
((DEFENSE_VARIABLES[date_up_sec]++)) && return 0

# 系统起来后经过的秒数
date_up_sec () { printf "%s" "$SECONDS" ; }

return 0

