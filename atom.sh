# 原子操作集合(理论上当前文件不应该引用任何其它文件)
# 注意:命令行参数大小限制,数组参数不能过大


((__ATOM++)) && {
    return
}

# 判断数据类型(不能判断一个数据是否是引用变量)
atom_identify_data_type ()
{
    local tmp_var_name="$1"
    local verify_type="$2"
    local up_var_name=
    local real_var_name=
    
    while : ; do
        if [[ "$(declare -p $tmp_var_name 2>/dev/null)" =~ ^declare\ [^=\ ]*n[^=\ ]*\ ([^\ ]+)=(.+) ]] ; then
            tmp_var_name=${BASH_REMATCH[2]#\"}
            tmp_var_name=${tmp_var_name%\"}
        else
            if [[ -z "$(declare -p $tmp_var_name 2>/dev/null)" ]] ; then
                return 1
            fi
            # 非引用变量就是我们要找的真实变量
            real_var_name="$tmp_var_name"
            break
        fi
    done
    
    if [[ "$(declare -p $real_var_name 2>/dev/null)" =~ ^declare\ [^=\ ]*"$verify_type"[^=\ ]*\ [^\ ]+=.+ ]] ; then
        return 0
    else
        return 1
    fi
}

atom_get_bash_version ()
{
    local major_version minor_version
    if [[ $BASH_VERSION =~ ([0-9]+)\.([0-9]+) ]]; then
        major_version=${BASH_REMATCH[1]}
        minor_version=${BASH_REMATCH[2]}
        printf "%s\n" "$major_version" "$minor_version"
    fi
}





#-------------------------------------------------------------
# 文件操作原子部分(第一个参数必须是文件名)---主要是为某些高阶函数准备的
# 追加打印信息到一个文件中
add_msg_to_file ()
{
    local file_name="$1"
    local msg="$2"

    echo "$msg" | tee -a "$file_name"
}

