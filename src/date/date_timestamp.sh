. ./meta/meta.sh
((DEFENSE_VARIABLES[date_timestamp]++)) && return 0

if ((__META_BASH_VERSION>=4002000)) ; then
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

