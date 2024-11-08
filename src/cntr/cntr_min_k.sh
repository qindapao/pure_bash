. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_min_k]++)) && return 0

# 返回容器中值最小的键
# 数值比较
# 1: 容器变量名字
# 2: 要返回的键的变量名
cntr_min_k () 
{ 
    eval -- '
    local i'$1$2' ; '$2'=''
    local m'$1$2'=""
    for i'$1$2' in "${!'$1'[@]}" ; do
        if [[ -z "$m'$1$2'" ]] ; then
            m'$1$2'="${'$1'[$i'$1$2']}"  
            '$2'=$i'$1$2'
        else
            if ((${'$1'[$i'$1$2']}<m'$1$2')) ; then
                m'$1$2'="${'$1'[$i'$1$2']}"  
                '$2'=$i'$1$2'
            fi
        fi
    done
    '
}

return 0

