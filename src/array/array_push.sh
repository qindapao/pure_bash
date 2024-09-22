. ./meta/meta.sh
((DEFENSE_VARIABLES[array_push]++)) && return 0

# 这个函数并没有用,直接操作更简单
array_push ()
{
    local -n _array_push_ref_arr=$1
    shift
    _array_push_ref_arr+=("${@}")
}

return 0

