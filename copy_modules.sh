#! /usr/bin/bash
. ./copy_modules.cfg

# 首先需要进入源码目录
cd ./src

DIR_NAME="./copy_modules"
rm -rf "$DIR_NAME"
mkdir -p "$DIR_NAME"

copy_modules ()
{
    local all_modules=("${@}")
    local cur_file=''
    local des_dir=''
    local des_file=''
    local i

    # meta是一定要拷贝的,先处理
    mkdir -p "${DIR_NAME}/meta"
    cp -f ./meta/meta.sh "${DIR_NAME}/meta/meta.sh"

    while ((${#all_modules[@]})) ; do
        # 处理栈顶文件
        cur_file="${all_modules[-1]}"
        unset 'all_modules[-1]'
        des_file="${DIR_NAME}${cur_file:1}"
        des_dir=${des_file%/*}
        mkdir -p "$des_dir"
        cp -f "$cur_file" "$des_file"

        # 进入栈顶文件内部，查看其引用的文件
        local -a source_file=()
        mapfile -t source_file < "$cur_file"
        for i in "${source_file[@]}" ; do
            if [[ "$i" =~ ^\.\ +([^| ]+)\ +\|\|\ +return\ +1 ]] ; then
                all_modules+=("${BASH_REMATCH[1]}")
            fi
        done
    done
}

copy_modules "${COPY_MODULES[@]}"

