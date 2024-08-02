. ./meta/meta.sh
((DEFENSE_VARIABLES[str_count_char]++)) && return 0

# 单字符统计(只能统计单字符)
# 1: 字符串值
# 2: 被统计字符值(如果是长度非1,那么多个字符都统计)
# 3: 需要保存结果变量(如果没有就打印到标准输出)
str_count_char ()
{
    if [[ -n "$2" ]] ; then
        eval -- 'local only_char_'$3'=${1//[!"$2"]}'
    else
        eval -- 'local only_char_'$3'='
    fi

    if [[ -n "$3" ]] ; then
        eval -- ''$3'=${#only_char_'$3'}'
    else
        eval -- 'printf "%s" "${#only_char_'$3'}"'
    fi
}

return 0

