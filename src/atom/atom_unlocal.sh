. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_unlocal]++)) && return 0

if ((__META_BASH_VERSION>=5002000)) ; then
atom_unlocal ()
{
    if shopt -q localvar_unset ; then
        shopt -u localvar_unset
        unset -v "$@" ; set -- "$?"
        shopt -s localvar_unset
        return "$1"
    else
        unset -v "$@"
    fi
}
else
atom_unlocal () { unset -v "$@" ; }
fi

return 0

