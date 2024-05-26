. ./meta.sh
((DEFENSE_VARIABLES[date]++)) && return

. ./atom.sh

atom_get_bash_version __str_bash_major_version __str_bash_minor_version
if ((__str_bash_major_version>=4)) && ((__str_bash_minor_version>=2)) ; then
    date_prt_t ()
    {
        printf '%(%Y-%m-%dT%H:%M:%S)T' -1
    }

    date_prt ()
    {
        printf '%(%Y-%m-%d %H:%M:%S)T' -1
    }

    date_log ()
    {
        printf '%(%Y_%m_%d_%H_%M_%S)T' -1
    }

    # 这样也可以为外部变量赋值,或者使用read,简单场景不一定要使用变量的间接引用,和引用变量一个效果
    # printf -v "$1" "%(%s)T" "-1"
    date_timestamp ()
    {
        printf "%(${1})T" "-1"
    }

else
    date_prt_t ()
    {
        date +"%y-%m-%dT%H:%M:%S"
    }

    date_prt ()
    {
        date +"%y-%m-%d %H:%M:%S"
    }

    date_log ()
    {
        date +'%Y_%m_%d_%H_%M_%S'
    }

    date_timestamp ()
    {
        date +"$1"
    }

fi

date_print_elapsed_time ()
{
    printf "Elapsed time: %d days %02d:%02d:%02d.\n" $((SECONDS/(24*60*60))) $(((SECONDS/(60*60))%24)) $(((SECONDS/60)%60)) $((SECONDS%60))
}

# 系统起来后经过的秒数
date_up_sec () { printf "%s" "$SECONDS" ; }

