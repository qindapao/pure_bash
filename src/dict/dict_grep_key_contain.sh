. ./meta/meta.sh
((DEFENSE_VARIABLES[dict_grep_key_contain]++)) && return 0

# 截取键包含特定关键字的键值对,返回新关联数组
# 1: 保存的新数组
# 2: 原始数组
# 3: 需要匹配的关键字
dict_grep_key_contain ()
{
    local _script_${1}${2}='
        '$1'=()
        local i'$1$2'
        for i'$1$2' in "${!'$2'[@]}"; do
            if [[ "${i'$1$2'}" == *"${3}"* ]] ; then
                '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
            fi
        done'
    eval -- eval -- \"\$"_script_${1}${2}"\"
    true
}

return 0

