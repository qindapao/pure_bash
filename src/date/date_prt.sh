. ./meta/meta.sh
((DEFENSE_VARIABLES[date_prt]++)) && return 0

if ((__META_BASH_VERSION>=4002000)) ; then
    date_prt ()
    {
        [[ -n "${1}" ]] && {
            printf -v "${1}" '%(%Y-%m-%d %H:%M:%S)T' -1
        } || {
            printf '%(%Y-%m-%d %H:%M:%S)T' -1
        }
    }
else
    date_prt ()
    {
        [[ -n "${1}" ]] && {
            printf -v "${1}" "$(date +"%y-%m-%d %H:%M:%S")"
        } || {
            date +"%y-%m-%d %H:%M:%S"
        }
    }
fi

return 0

