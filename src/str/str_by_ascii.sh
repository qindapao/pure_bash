. ./meta/meta.sh
((DEFENSE_VARIABLES[str_by_ascii]++)) && return 0

. ./atom/atom_eval_p.sh || return 1
. ./str/str_join.sh || return 1

# 通过ascii数组生成字符串
# 1: 保存的变量名
# 2: 需要拼接的数组名
str_by_ascii ()
{
    local s_$1$2=''
    {
    IFS= read -r -d '' s_$1$2 <<'    EOF'

    S1=''
    if ((${#A1[@]})) ; then
        str_join -v S1 '\x' "${A1[@]}"
        S1='\x'$S1
        printf -v S1 "$S1"
    fi

    EOF
    } || true
    atom_eval_p "s_$1$2" S1 "$1" A1 "$2" 
    eval -- eval -- '"${s_'$1$2'}"'
}

return 0

