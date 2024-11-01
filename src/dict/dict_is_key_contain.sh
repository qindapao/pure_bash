. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_is_key_contain]++)) && return 0

# 判断关联数组的键是否包含一个字符串
dict_is_key_contain ()
{
    eval -- '
        local i'$1'
        local -i i'$1'_contain=0
        for i'$1' in "${!'$1'[@]}"; do
            if [[ "${i'$1'}" == *"${2}"* ]] ; then
                i'$1'_contain=1
                break
            fi
        done
        ((i'$1'_contain))
    '
}

return 0

