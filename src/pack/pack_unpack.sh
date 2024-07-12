. ./meta/meta.sh
((DEFENSE_VARIABLES[pack_unpack]++)) && return 0

# :TODO: 是否库中的函数,所有的正常信息都应该输出到标准输出,所有的异常信息都应该
#        输出到标准错误
# :TODO: 添加支持的更多的后缀
# 用法:
#       pack_unpack 1.tar.gz 2.tgz 3.zip
# 返回值:
#   0: 执行成功
#   1: 执行失败
#       执行失败会在标准错误中打印具体的出错信息
#  :TODO: 这里有一些实用函数
#  https://github.com/ohmybash/oh-my-bash/blob/master/lib/functions.sh
pack_unpack ()
{
    local file_path
    local -i ret_code=0

    # 不带in "${@}" 默认就是对所有位置参数遍历
    for file_path ; do
        [[ -f "$file_path" ]] || {
            printf "%s\n" "${file_path} is not a valid file." >&2
            continue
        }
        case "$file_path" in
        *.tar.gz|*.tgz)   
                tar xzvf "$file_path" ;;
        *.bz2)  tar xjvf "$file_path" ;;
        *.zip)  unzip "$file_path" ;;
        *.rar)  unrar e "$file_path"     ;;
        *.gz)   gunzip "$file_path"      ;;
        *.tar)  tar xf "$file_path"      ;;
        *.tbz2) tar xjf "$file_path"     ;;
        *.Z)    uncompress "$file_path"  ;;
         *.7z)  7z x "$file_path"        ;;
        *)      printf "%s\n" "can not unpack $file_path" >&2
                ret_code=1
                ;;
        esac
    done

    return $ret_code
}

return 0

