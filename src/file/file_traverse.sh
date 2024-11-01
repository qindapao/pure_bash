# 文件操作函数集

. ./meta/meta.sh
((DEFENSE_VARIABLES[file_traverse]++)) && return 0

# 下面函数也可以使用递归实现，但是递归的弊端是有调用栈限制,尽量别用
# 如果要遍历当前文件夹,下面这样传参
# file_traverse '.'
# 函数支持遍历多个目录
file_traverse () 
{
    local all_dirs=("${@}")  # 初始化包含起始目录的栈
    local cur_dir            # 当前正在处理的目录
    local cur_file           # 当前正在处理的文件

    # 当栈不为空时，处理栈顶的目录
    while ((${#all_dirs[@]})) ; do
        cur_dir="${all_dirs[-1]}"  # 获取栈顶目录（数组的最后一个元素）
        unset -v 'all_dirs[-1]'       # 弹出栈顶目录,这里一定要用单引号而不是双引号,这里下标如果是变量也可以支持

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

return 0

