#! /usr/bin/bash
. ./copy_modules.cfg

# :TODO: 拷贝完成后还需要手动调整下别名全局变量和函数的位置,别名最靠前,然后是全局变量
#        虽然当前函数已经处理了依赖关系,最低依赖在最上面,依次往下排列,但是为了安全起见
#        还是应该把所有的别名放置到最前面,然后是全局变量,最后是函数定义
# 最后才是函数
# 首先需要进入源码目录
cd ./src
. ./log/log_dbg.sh || return 1
. ./file/file_del_end_pattern.sh || return 1
. ./file/file_del_pattern.sh || return 1
. ./str/str_basename.sh || return 1


LOG_LEVEL=3
LOG_ALLOW_BREAK=1


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

    # 使用动态关联数组记录每一个文件所依赖的文件,如果所有依赖的文件都已经被处理,那么
    # 它才可以拷贝

    # meta是一定要拷贝的,先处理(所以后面不能的列表中不能包含它)
    cat ./meta/meta.sh | grep -v '^((__META++))' |\
                         file_del_end_pattern_pipe '^[[:space:]]*$' |\
                         file_del_end_pattern_pipe '^[[:space:]]*return[[:space:]]*0[[:space:]]*$' >>"$SINGLE_FILE_NAME"
    echo "#-----------------" >>"$SINGLE_FILE_NAME"
    
    ldebug_bp 'show all_modules' all_modules

    while ((${#all_modules[@]})) ; do
        # 取出栈顶文件
        cur_file="${all_modules[-1]}"

        # 获取它依赖的文件(如果有)
        local -i is_need_check_depend=0

        local cur_file_base_name="$cur_file" ; str_basename cur_file_base_name
        local -A "${cur_file_base_name}"_depend
        local -n cur_file_ref_hash="${cur_file_base_name}"_depend

        ldebug_bp 'show ref hash' all_modules file_have_deal cur_file cur_file_ref_hash

        if ((${#cur_file_ref_hash[@]})) ; then
            ((is_need_check_depend++)) 
        else
            # 进入栈顶文件内部，查看其引用的文件
            local -a source_file=()
            mapfile -t source_file < "$cur_file"
            for i in "${source_file[@]}" ; do
                if [[ "$i" =~ ^\.\ +([^| ]+)\ +\|\|\ +return\ +1[[:space:]]*$ ]] ; then
                    # 已经被处理过的文件不再压入,既然已经处理证明它所依赖的文件也已经处理
                    # 所以它不需要压入
                    [[ "${file_have_deal[${BASH_REMATCH[1]}]+set}" ]] || {
                        all_modules+=("${BASH_REMATCH[1]}")
                    }
                    cur_file_ref_hash[${BASH_REMATCH[1]}]=1
                    ((is_need_check_depend++))
                fi
            done
        fi

        # 检查依赖的文件是否全部处理完了
        local -i is_can_deal=1
        if ((is_need_check_depend)) ; then
            local tmp_file
            for tmp_file in "${!cur_file_ref_hash[@]}" ; do
                [[ "${file_have_deal[$tmp_file]+set}" ]] || is_can_deal=0
            done
        fi

        ((is_can_deal)) && {
            # 如果没有被处理就处理,否则标记为已经处理
            if ! [[ "${file_have_deal["$cur_file"]+set}" ]] ; then
                file_have_deal["$cur_file"]=1
                
                if (((${#ONLY_COPY_MODULES[@]})) && [[ "${ONLY_COPY_MODULES[$cur_file]:+set}" ]]) ||
                    ! ((${#ONLY_COPY_MODULES[@]})) ; then
                    cat "$cur_file" | grep -v '^. ./meta/meta.sh' |\
                                      grep -v '^((DEFENSE_VARIABLES' |\
                                      file_del_end_pattern_pipe '^[[:space:]]*$' |\
                                      file_del_end_pattern_pipe '^[[:space:]]*return[[:space:]]*0[[:space:]]*$' |\
                                      file_del_pattern_pipe '^\.\ +([^| ]+)\ +\|\|\ +return\ +1[[:space:]]*$' >>"$SINGLE_FILE_NAME"
                    echo "#-----------------" >>"$SINGLE_FILE_NAME"
                fi
            fi
            # 移除栈顶元素(这个时候元素一定在栈顶)
            unset -v 'all_modules[-1]'
        }
    done

    # :TODO: 修改拷贝后的文件，把别名拷贝到最上面(暂时不处理全局变量)
}

copy_modules "${COPY_MODULES[@]}"

