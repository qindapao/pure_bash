. ./meta/meta.sh
((DEFENSE_VARIABLES[str_splits]++)) && return 0

. ./str/str_index_of.sh || return 1
. ./atom/atom_func_upstr.sh || return 1

# :TODO: 是否有必要模拟awk处理多行字符串?
# 字符串裁剪成数组
# 1: 字符串
# 2: 分隔符(如果为空表示使用内置的分隔符)
# 3: 是否大小写敏感(默认0大小写敏感)
# 如果截取失败,最终的结果是输入字符串
str_splits ()
{
    ret_arr=()
    local ret_index
    local in_str=$1
    local delim=$2
    local is_ignorecase=${3:-0}

    [[ "$delim" ]] || {
        if [[ -o noglob ]]; then
            ret_arr=($in_str)
        else
            local - ; set -f ; ret_arr=($in_str) ; set +f
        fi
        return
    }

    if ((is_ignorecase)) ; then
        # 大小写不敏感拆分
        local in_str_i=${in_str,,} delim_i=${delim,,} 
        local -i delim_len=${#delim}
        while [[ "$in_str_i" ]] ; do
            if atom_func_upstr ret_index \
                str_index_of "$in_str_i" "$delim_i" ; then
                ret_arr+=("${in_str:0:ret_index}")
                in_str=${in_str:ret_index+delim_len}
                in_str_i=${in_str_i:ret_index+delim_len}
            else
                ret_arr+=("$in_str")
                break
            fi
        done
    else
        while [[ "$in_str" ]] ; do
            if [[ "$in_str" == *"$delim"* ]] ; then
                ret_arr+=("${in_str%%"$delim"*}")
                in_str=${in_str#*"$delim"}
            else
                ret_arr+=("$in_str")
                break
            fi
        done
    fi
}

return 0

