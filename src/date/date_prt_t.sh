. ./meta/meta.sh
((DEFENSE_VARIABLES[date_prt_t]++)) && return 0

. ./date/date_vars.sh || return 1

if ((__date_vars_bash_major_version>=4)) && ((__date_vars_bash_minor_version>=2)) ; then
    date_prt_t ()
    {
        [[ -n "${1}" ]] && {
            printf -v "${1}" '%(%Y-%m-%dT%H:%M:%S)T' -1
        } || {
            printf '%(%Y-%m-%dT%H:%M:%S)T' -1
        }
    }

else
    date_prt_t ()
    {
        [[ -n "${1}" ]] && {
            printf -v "${1}" $(date +"%y-%m-%dT%H:%M:%S")
        } || {
            date +"%y-%m-%dT%H:%M:%S"
        }
    }
fi

return 0

