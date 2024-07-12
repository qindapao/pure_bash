. ./meta/meta.sh
((DEFENSE_VARIABLES[struct_copy]++)) && return 0

# 结构体拷贝,其实就是数组的拷贝或者关联数组的拷贝
struct_copy ()
{
    local -n _struct_copy_old=$1 _struct_copy_new=$2
    local _struct_copy_index

    _struct_copy_new=()

    for _struct_copy_index in "${!_struct_copy_old[@]}" ; do
        _struct_copy_new["${_struct_copy_index}"]="${_struct_copy_old["$_struct_copy_index"]}"
    done
}

return 0

