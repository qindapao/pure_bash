. ./meta/meta.sh
((DEFENSE_VARIABLES[date_is_leep_year]++)) && return 0

date_is_leep_year () { ((($1%4==0&&$1%100!=0)||$1%400==0)) ; }

return 0

