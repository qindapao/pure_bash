. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_extend]++)) && return 0

. ./atom/atom_is_varname_valid.sh || return 1

# 追加一个容器中的内容完全到另外一个容器中
# $1 $2: 把容器2中的内容追加到容器1中
# 这个函数可以支持关联数组
cntr_extend ()
{
    atom_is_varname_valid "$1" "$2" || return 1
    eval -- 'local i'$1$2'
        for i'$1$2' in "${!'$2'[@]}"; do
          '$1'["${i'$1$2'}"]="${'$2'["${i'$1$2'}"]}"
        done ; true'
}

return 0

