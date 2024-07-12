. ./meta/meta.sh
((DEFENSE_VARIABLES[date_prt_t]++)) && return 0

if ((__META_BASH_VERSION>=4002000)) ; then
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

