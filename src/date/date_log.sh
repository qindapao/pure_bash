. ./meta/meta.sh
((DEFENSE_VARIABLES[date_log]++)) && return 0

. ./date/date_vars.sh || return 1

if ((__date_vars_bash_major_version>=4)) && ((__date_vars_bash_minor_version>=2)) ; then
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

