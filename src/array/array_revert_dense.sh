. ./meta/meta.sh
((DEFENSE_VARIABLES[array_revert_dense]++)) && return 0

array_revert_dense ()
{
    eval "
    set -- \"\${$1[@]}\"; $1=()
    local e$1 i$1=\$#
    for e$1; do $1[--i$1]=\"\$e$1\"; done"
}

return 0

