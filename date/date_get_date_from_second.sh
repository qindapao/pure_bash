. ./meta/meta.sh
((DEFENSE_VARIABLES[date_get_date_from_second]++)) && return 0

. ./date/date_is_leep_year.sh || return 1
. ./date/date_get_year_days.sh || return 1

# 从某一年的 01-01 00:00:00 以来经过的秒数计算具体的日期,比如: 1996-01-01 00:00:00
date_get_date_from_second ()
(
    # 开始的年份
    local -i cur_year="${1}"
    # 经过的秒数
    local -i get_second="${2}"
    local -a mon_to_day_noleap_year=(0 31 59 90 120 151 181 212 243 273 304 334 365)
    local -a mon_to_day_leap_year=(0 31 60 91 121 152 182 213 244 274 305 335 366)
    # 一天的秒数
    local -i second_day=86400
    # 一个小时的秒数
    local -i second_hour=3600
    # 一分钟的秒数
    local -i second_min=60

    local -i left_days=$((get_second/second_day))
    local -i days_cur_year
    local -i out_year loop_i cur_mon_yday out_month out_day
    local -i pre_mon_yday out_sec out_hour out_min left_sec

    days_cur_year=$(date_get_year_days "$cur_year")

    while ((left_days>=days_cur_year))
    do
        ((left_days-=days_cur_year))
        ((cur_year++))
        days_cur_year=$(date_get_year_days "$cur_year")
    done
    out_year=${cur_year}

    # 计算月和日
    for((loop_i=1;loop_i<13;loop_i++))
    do
        if date_is_leep_year "$cur_year" ; then
            cur_mon_yday=${mon_to_day_leap_year[loop_i]}
            pre_mon_yday=${mon_to_day_leap_year[loop_i-1]}
        else
            cur_mon_yday=${mon_to_day_noleap_year[loop_i]}
            pre_mon_yday=$[mon_to_day_noleap_year[loop_i-1]]
        fi

        if ((left_days<cur_mon_yday)) ; then
            out_month=$loop_i
            ((out_day=left_days-pre_mon_yday+1))
            break
        fi
    done

    # 获取时间
    left_sec=$((get_second%second_day))
    out_hour=$((left_sec/second_hour))
    out_min=$(((left_sec%second_hour)/second_min))
    out_sec=$((left_sec%second_min))

    printf "%04d-%02d-%02d-%02d-%02d-%02d" "$out_year" "$out_month" "$out_day" "$out_hour" "$out_min" "$out_sec"
)

return 0

