. ./meta/meta.sh
((DEFENSE_VARIABLES[str_count_str]++)) && return 0

# 子字符串数量统计
# 1: 字符串值
# 2: 被统计字符串值
# 3: 需要保存结果变量(如果没有就打印到标准输出)
str_count_str ()
{
    case "$2" in
    '')
        if [[ -n "$3" ]] ; then
            eval ''$3'=0'
        else
            printf "%s" "0"
        fi
        ;;
    *)
        eval -- 'local cnt_str_'$3'=${1//"$2"}'
        if [[ -n "$3" ]] ; then
            eval -- '(('$3'=(${#1}-${#cnt_str_'$3'})/${#2}))'
        else
            eval -- 'printf "%s" $(((${#1}-${#cnt_str_'$3'})/${#2}))'
        fi
        ;;
    esac
    return 0
}

return 0

