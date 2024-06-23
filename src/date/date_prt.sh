. ./meta/meta.sh
((DEFENSE_VARIABLES[date_prt]++)) && return 0

. ./date/date_vars.sh || return 1

if ((__date_vars_bash_major_version>=4)) && ((__date_vars_bash_minor_version>=2)) ; then
    date_prt ()
    {
        printf '%(%Y-%m-%d %H:%M:%S)T' -1
    }
else
    date_prt ()
    {
        date +"%y-%m-%d %H:%M:%S"
    }
fi

return 0

