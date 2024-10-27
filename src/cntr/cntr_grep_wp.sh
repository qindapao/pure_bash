. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_grep_wp]++)) && return 0

. ./cntr/cntr_grep.sh || return 1

# grep的子函数带除数组3参数以外的另外参数的情况
# wp是with params的意思
cntr_grep_wp ()
{
    cntr_grep "${@:1:2}" '' '' "${@:3}"
}

return 0

