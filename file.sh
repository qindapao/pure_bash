# 文件操作函数集

. ./meta.sh
((DEFENSE_VARIABLES[file]++)) && return

# 下面函数也可以使用递归实现，但是递归的弊端是有调用栈限制,尽量别用
# 如果要遍历当前文件夹,下面这样传参
# file_traverse '.'
# 函数支持遍历多个目录
file_traverse() 
{
    local all_dirs=("${@}")  # 初始化包含起始目录的栈
    local cur_dir            # 当前正在处理的目录
    local cur_file           # 当前正在处理的文件

    # 当栈不为空时，处理栈顶的目录
    while ((${#all_dirs[@]})) ; do
        cur_dir="${all_dirs[-1]}"  # 获取栈顶目录（数组的最后一个元素）
        unset 'all_dirs[-1]'       # 弹出栈顶目录,这里一定要用单引号而不是双引号,这里下标如果是变量也可以支持

        # 遍历当前目录下的所有文件和目录
        for cur_file in "$cur_dir"/* ; do
            if [[ -d "$cur_file" ]] ; then
                # 如果是目录，则将其推入栈中
                all_dirs+=("$cur_file")
            else
                if [[ "$cur_file" == "${cur_dir}/*" ]] && [[ ! -f "${cur_dir}/*" ]] ; then
                    # 这表示一个空目录
                    cur_file="${cur_file:0:-2}"
                fi
                # 输出文件或者空目录的路径
                printf "%s\n" "$cur_file"
            fi
        done
    done
}

# 从某个目录开始查找一个普通文件(属性是-f)并且在查找的过程中排除某些目录(某些目录文件太多导致性能低下)
# find "/" -path "/proc" -prune -o -type f -name "we_are_here_to_find_binary_dir" -print
# 1: 文件名
file_find ()
{
    local find_root_dir="${1}"  find_exclude_dir="${2}" find_file_name="${3}"
    find "${find_root_dir}" -path "$find_exclude_dir" -prune -o -type f -name "$find_file_name" -print
}

# 查找一个目录下的保护下列条件的文件名
# 1. 文件名包含 PropertyProductConfig 和 ${BOMCODE}
# 2. 文件名不包含 PropertyProductConfig
# read -d '' -r -a ALL_PROPERTY_FILES < <(find "$HARDPARAM_PROPERTY_PAGE_PATH" -type f \( -name "*PropertyProductConfig*${BOMCODE}*" -o ! -name "*PropertyProductConfig*" \))


