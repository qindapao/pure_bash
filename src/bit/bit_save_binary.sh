. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_save_binary]++)) && return 0

. ./atom/atom_is_varname_valid.sh || return 1

# https://stackoverflow.com/questions/2003803/show-hexadecimal-numbers-of-a-file
# :TODO: 可以模仿上面的函数做一个bash内置的hexdump
# 保存一个二进制文件所有bit到一个变量中
# 参数: 1 最终保存的字符串名
#       2 读取的二进制文件的完整路径
# 这个函数速度很快
# :TODO: bash无法处理$'\0'的空字符,需要确认下二进制数据中是否可能包含空字符
bit_save_binary ()
{
    atom_is_varname_valid "$1" || return 1
    [[ "${2:+set}" ]] || return 1

    # 默认值是 C.UTF-8 不能正常工作
    # C.UTF-8，表示使用 UTF-8 编码的英语环境。
    # C 语言环境使用的是 ASCII 编码，不会对字符进行额外的处理，因此适用于处理二进制数据。
    local LANG=C
    local _bit_save_binary_block_str_${1}='
        local i'${1}'_char i'${1}'_tmp_str

        while IFS= read -s -d '\'''\'' -r -n 1 i'${1}'_char ; do
            printf -v i'${1}'_tmp_str "\\\\x%02x" "'\''$i'${1}'_char"
            '${1}'+="$i'${1}'_tmp_str"
        # 为了安全对于不确定的字符串先不求值
        done < "${2}"
        '

    eval -- eval -- \"\$"_bit_save_binary_block_str_${1}"\"
    true
}

return 0

