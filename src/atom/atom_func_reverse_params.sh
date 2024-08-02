. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_func_reverse_params]++)) && return 0

# 别名调试的方式
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/set# IFS= read -r -d '' xx <<'EOF'
# eval -- eval -- 'eval -- '\''set -- \"\$\{{'$#'..1}\}\"'\'''
# EOF
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/set# declare -p xx
# declare -- xx="eval -- eval -- 'eval -- '\\''set -- \\\"\\\$\\{{'\$#'..1}\\}\\\"'\\'''
# "
# root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/test/cases/set# 
# 下面这个别名的作用是翻转函数的参数列表
alias atom_func_reverse_params="eval -- eval -- 'eval -- '\\''set -- \\\"\\\$\\{{'\$#'..1}\\}\\\"'\\'''"

return 0

