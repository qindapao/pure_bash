. ./meta/meta.sh
((DEFENSE_VARIABLES[eval_pack]++)) && return 0

# 把表达式增加一层
# @Q操作符和%q转换的格式有细微差异,但是效果一样
# @Q操作符对普通字符也会保护,%q不会
# 1: 打包的字符串
# 2: (可选)打包的层级
if ((__META_BASH_VERSION>=4004000)) ; then

eval_pack () 
{ 
    eval -- "$1=\${!1@Q}"
    if [[ -n "$2" ]] ; then
        local lev_${1}=$2
        eval -- '
            ((lev_'${1}'--))
            while ((lev_'${1}'--)) ; do '$1'=${!1@Q} ; done
        '
    fi
    return 0
}

elif ((__META_BASH_VERSION>=4002000)) ; then

eval_pack ()
{ 
    printf -v "$1" "%q" "${!1}"
    if [[ -n "$2" ]] ; then
        local lev_${1}=$2
        eval -- '
            ((lev_'${1}'--))
            while ((lev_'${1}'--)) ; do printf -v "$1" "%q" "${!1}" ; done
        '
    fi
    return 0
}

else
    # :TODO: 手动转义的实现,可能比较复杂
    :
fi

return 0

