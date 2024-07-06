. ./meta/meta.sh
((DEFENSE_VARIABLES[date_log]++)) && return 0

if ((__META_BASH_VERSION>=4002000)) ; then
    date_log ()
    {
        [[ -n "${1}" ]] && {
            printf -v "${1}" '%(%Y_%m_%d_%H_%M_%S)T' -1
        } || {
            printf '%(%Y_%m_%d_%H_%M_%S)T' -1
        }
    }
else
    date_log ()
    {
        [[ -n "${1}" ]] && {
            printf -v "${1}" $(date +'%Y_%m_%d_%H_%M_%S')
        } || {
            date +'%Y_%m_%d_%H_%M_%S'
        }
    }
fi

return 0

