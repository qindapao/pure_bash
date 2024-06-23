# 所有用例公共函数依赖的东西
((__TEST_META++)) && return 0 

declare -gA TEST_DEFENSE_VARIABLES=([test_meta]=1 )
# 脚本中启用别名扩展(默认关闭)
shopt -s expand_aliases

return 0

