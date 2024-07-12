. ./meta/meta.sh
((DEFENSE_VARIABLES[str_join]++)) && return 0

# join_str=$(str_join '--' "${array[@]}")
# 不太可能用于高阶函数
str_join ()
{
    local connector=$1
    shift
    local join_str
    join_str=$(printf "%s${connector}" "${@}")
    printf "%s" "${join_str%"$connector"*}"
}

return 0

