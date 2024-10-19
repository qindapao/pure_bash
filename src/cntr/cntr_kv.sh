. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_kv]++)) && return 0

if ((__META_BASH_VERSION>=5002000)) ; then
cntr_kv () { eval "$1=(\"\${$2[@]@k}\")" ; }
else
cntr_kv ()
{
    eval -- 'local i'$1''$2' ; '$1'=()
    for i'$1''$2' in "${!'$2'[@]}" ; do
        '$1'+=("$i'$1''$2'" "${'$2'[$i'$1''$2']}")
    done
    '
}
fi

return 0

