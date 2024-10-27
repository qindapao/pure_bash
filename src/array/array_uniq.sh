. ./meta/meta.sh
((DEFENSE_VARIABLES[array_uniq]++)) && return 0

# 去重一个数组中的元素,原地更新数组,保持原始顺序
array_uniq ()
{
    local _array_uniq_script_$1='
    local eNAME 
    local cNAME=("${NAME[@]}") ; NAME=()
    local -A dictNAME=()
    for eNAME in "${cNAME[@]}" ; do 
        [[ -n "${dictNAME[x$eNAME]}" ]] && continue
        NAME+=("$eNAME") ; dictNAME[x$eNAME]=1 
    done
    '
    eval -- eval -- '"${_array_uniq_script_'$1'//NAME/$1}"'
}

return 0

