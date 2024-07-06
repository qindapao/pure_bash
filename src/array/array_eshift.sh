. ./meta/meta.sh
((DEFENSE_VARIABLES[array_eshift]++)) && return 0

# 从数组的头部掉一个元素下来
# array_eshift "arr_name" 'ret'
array_eshift ()
{
    eval "((\${#$1[@]}))" || return 1
    eval -- "$2=\"\${$1[0]}\""
    eval -- "$1=(\"\${$1[@]:1}\")"
    return 0
}

return 0

