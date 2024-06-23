. ./meta/meta.sh
((DEFENSE_VARIABLES[date_get_year_days]++)) && return 0

. ./date/date_is_leep_year.sh || return 1

date_get_year_days ()
{
    local -i year="${1}"
    date_is_leep_year && printf "366" || printf "365"
}

return 0

