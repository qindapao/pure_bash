. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_copy]++)) && return 0

. ./atom/atom_is_varname_valid.sh || return 1

# 拷贝一个数组到另外一个数组中
# $1 $2: 把$2数组拷贝到$1
# 这个函数可以支持关联数组
cntr_copy ()
{
    atom_is_varname_valid "$1" "$2" || return 1
    eval -- ''$1'=() ; local i'$1$2'
        for i'$1$2' in "${!'$2'[@]}"; do
          '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
        done ; true'
}

return 0

