. ./meta/meta.sh
((DEFENSE_VARIABLES[date_get_year_days]++)) && return 0

. ./date/date_is_leep_year.sh || return 1

date_get_year_days ()
{
    date_is_leep_year "$1" && printf "366" || printf "365"
}

return 0

