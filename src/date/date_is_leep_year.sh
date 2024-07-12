. ./meta/meta.sh
((DEFENSE_VARIABLES[date_is_leep_year]++)) && return 0

date_is_leep_year ()
{
    local -i year=$1
    (((year%4==0&&year%100!=0)||year%400==0))
}

return 0

