. ./meta/meta.sh
((DEFENSE_VARIABLES[date_timestamp]++)) && return 0

. ./date/date_vars.sh || return 1

if ((__date_vars_bash_major_version>=4)) && ((__date_vars_bash_minor_version>=2)) ; then
    # 这样也可以为外部变量赋值,或者使用read,简单场景不一定要使用变量的间接引用,和引用变量一个效果
    # printf -v "$1" "%(%s)T" "-1"
    date_timestamp ()
    {
        printf "%(${1})T" "-1"
    }
else
    date_timestamp ()
    {
        date +"$1"
    }
fi

return 0

