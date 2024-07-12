#! /usr/bin/bash
. ./copy_modules.cfg

# :TODO: 这个脚本有个重大的BUG，就是依赖树的关系，必须依赖的文件拷贝到文件的前面，因为别名的定义必须提前
#        防止后面的函数扫描的时候别名还未定义，造成代码没有正常展开
#        有一个最简单的方法，就是拷贝到单一的文件后手动把所有的别名定义放到脚本最开始的位置处
#        如果是直接使用当前的库，那么什么都不用处理，因为库已经自动处理了依赖关系了
# :TODO: 拷贝完成后还需要手动调整下别名全局变量和函数的位置,别名最靠前,然后是全局变量
# 最后才是函数
# 首先需要进入源码目录
cd ./src
. ./file/file_del_end_pattern.sh || return 1
. ./file/file_del_pattern.sh || return 1

DIR_NAME="./copy_modules"
rm -rf "$DIR_NAME"
mkdir -p "$DIR_NAME"
SINGLE_FILE_NAME="$DIR_NAME"/single_modules.sh
> "$SINGLE_FILE_NAME"

copy_modules ()
{
    local all_modules=("${@}")
    local cur_file='' des_dir='' des_file='' i
    # 关联数组记录处理过的文件
    local -A file_have_deal=()

    # meta是一定要拷贝的,先处理
    cat ./meta/meta.sh | grep -v "__META" |\
                         file_del_end_pattern_pipe '^\s*$' |\
                         file_del_end_pattern_pipe '^\s*return\s*0\s*$' >>"$SINGLE_FILE_NAME"
    echo "#-----------------" >>"$SINGLE_FILE_NAME"

    while ((${#all_modules[@]})) ; do
        # 处理栈顶文件
        cur_file="${all_modules[-1]}"
        unset 'all_modules[-1]'
        
        # 检查是否已经处理过
        [[ "${file_have_deal[$cur_file]:+set}" ]] && continue || file_have_deal["$cur_file"]=1

        cat "$cur_file" | grep -v '. ./meta/meta.sh' |\
                          grep -v '((DEFENSE_VARIABLES' |\
                          file_del_end_pattern_pipe '^\s*$' |\
                          file_del_end_pattern_pipe '^\s*return\s*0\s*$' |\
                          file_del_pattern_pipe '^\.\ +([^| ]+)\ +\|\|\ +return\ +1\s*$' >>"$SINGLE_FILE_NAME"
        echo "#-----------------" >>"$SINGLE_FILE_NAME"

        # 进入栈顶文件内部，查看其引用的文件
        local -a source_file=()
        mapfile -t source_file < "$cur_file"
        for i in "${source_file[@]}" ; do
            if [[ "$i" =~ ^\.\ +([^| ]+)\ +\|\|\ +return\ +1\s*$ ]] ; then
                all_modules+=("${BASH_REMATCH[1]}")
            fi
        done
    done
}

copy_modules "${COPY_MODULES[@]}"

