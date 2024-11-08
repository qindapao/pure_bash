. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_kv]++)) && return 0

. ./atom/atom_eval_p.sh || return 1

if ((__META_BASH_VERSION>=5002000)) ; then
cntr_kv () { eval "$1=(\"\${$2[@]@k}\")" ; }
else
cntr_kv ()
{
    local script_$1$2='
    local iC1C2 ; C1=()
    for iC1C2 in "${!C2[@]}" ; do
        C1+=("$iC1C2" "${C2[$iC1C2]}")
    done
    '
    atom_eval_p "script_$1$2" C1 "$1" C2 "$2"
    eval -- eval -- '"${script_'$1$2'}"'
}
fi

return 0

