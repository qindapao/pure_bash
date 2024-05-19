((__DATE_UTILS++)) && retun

. ./atom.sh

atom_get_bash_version __str_bash_major_version __str_bash_minor_version
if ((__str_bash_major_version>=4)) && ((__str_bash_minor_version>=2)) ; then
    date_prt ()
    {
        printf '%(%Y-%m-%d %H:%M:%S)T' -1
    }

    date_log ()
    {
        printf '%(%Y_%m_%d_%H_%M_%S)T' -1
    }

    # 这样也可以为外部变量赋值,或者使用read,简单场景不一定要使用变量的间接引用
    # printf -v "$1" "%(%s)T" "-1"
    date_timestamp ()
    {
        printf "%(%s)T" "-1"
    }

    # 使用给定的格式打印
    date_cur_datetime ()
    {
        printf "%(${1})T" "-1"
    }

    # 转换一个时间字符串
    date_datetime ()
    {
        printf "%(${2})T" "$1"
    }

    date_print_elapsed_time ()
    {
        printf "Elapsed time: %d days %02d:%02d:%02d.\n" $((SECONDS/(24*60*60))) $(((SECONDS/(60*60))%24)) $(((SECONDS/60)%60)) $((SECONDS%60))
    }
else
    date_prt ()
    {
        date +"%y-%m-%d %H:%M:%S"
    }

    date_log ()
    {
        date +'%Y_%m_%d_%H_%M_%S'
    }

    # :TODO: 实现使用date命令的方式
    date_timestamp ()
    {
        :
    }

    # 使用给定的格式打印
    date_cur_datetime ()
    {
        :
    }

    # 转换一个时间字符串
    date_datetime ()
    {
        :
    }

    date_print_elapsed_time ()
    {
        :
    }
fi

