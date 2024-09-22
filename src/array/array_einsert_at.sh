. ./meta/meta.sh
((DEFENSE_VARIABLES[array_einsert_at]++)) && return 0

# 在数组某个位置插入另外的元素
# 致密数组
array_einsert_at () 
{ 
    eval "$1=(\"\${$1[@]::$2}\" \"\${@:3}\" \"\${$1[@]:$2}\")"
}
return 0

