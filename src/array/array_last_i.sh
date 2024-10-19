. ./meta/meta.sh
((DEFENSE_VARIABLES[array_last_i]++)) && return 0

# 返回数组的最后一个index
array_last_i ()
{
    eval -- '
    local i'$1$2'=-1
    for i'$1$2' in "${!'$1'[@]}" ; do
        '$2'="$i'$1$2'"
    done
    '
}

return 0

