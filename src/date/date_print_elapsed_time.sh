. ./meta/meta.sh
((DEFENSE_VARIABLES[date_print_elapsed_time]++)) && return 0

# SECONDS 变量的含义是脚本运行的时间
date_print_elapsed_time ()
{
    printf "Elapsed time: %d days %02d:%02d:%02d.\n" $((SECONDS/(24*60*60))) $(((SECONDS/(60*60))%24)) $(((SECONDS/60)%60)) $((SECONDS%60))
}

return 0

