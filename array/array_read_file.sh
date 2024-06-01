. ./meta/meta.sh
((DEFENSE_VARIABLES[array_read_file]++)) && return 0


# 读取文件中的所有行并追加到一个数组中
array_read_file ()
{
    local -n _array_read_file_ref_arr="${1}"
    shift
    
    local _array_read_file_path

    for _array_read_file_path in "${@}" ; do
        [[ -s "$_array_read_file_path" ]] && {
            mapfile -t -O "${#_array_read_file_ref_arr[@]}" _array_read_file_ref_arr < "$_array_read_file_path"
        }
    done
}

return 0

