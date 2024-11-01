. ./meta/meta.sh
((DEFENSE_VARIABLES[sed_be_with_border]++)) && return 0

# 截取一段文本的开始关键字和结束关键字之间的行
# 并且包含边界行
# 由外部的代码或者程序保证关键字的唯一
sed_be_with_border ()
{
    local input_file
    case "$1" in
    -i) input_file=$PURE_STDIN ; shift ;;
    -f) input_file=$2 ; shift 2 ;;
    esac
    local begin=$1 end=$2

    sed -n "/${begin}/,/${end}/p" "$input_file"
}

alias sed_be_with_border_i='sed_be_with_border "-i"'
alias sed_be_with_border_f='sed_be_with_border "-f"'

return 0

