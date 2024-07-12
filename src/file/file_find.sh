. ./meta/meta.sh
((DEFENSE_VARIABLES[file_find]++)) && return 0

# 从某个目录开始查找一个普通文件(属性是-f)并且在查找的过程中排除某些目录(某些目录文件太多导致性能低下)
# find "/" -path "/proc" -prune -o -type f -name "we_are_here_to_find_binary_dir" -print
# 1: 文件名
file_find ()
{
    local find_root_dir=$1  find_exclude_dir=$2 find_file_name=$3
    find "${find_root_dir}" -path "$find_exclude_dir" -prune -o -type f -name "$find_file_name" -print
}

return 0

