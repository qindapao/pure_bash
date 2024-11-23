. ./meta/meta.sh
((DEFENSE_VARIABLES[str_to_ascii]++)) && return 0

# 字符串转换成16进制ascii字符串
str_to_ascii ()
{
    case "$#" in
    0)
    local value=
    IFS= read -d '' -r value || true
    local i
    local ascii_str tmp_str
    for ((i=0;i<${#value};i++)) ; do
        ascii_str+=${ascii_str:+ }
        printf -v tmp_str "%x" "'${value:i:1}"
        ascii_str+="$tmp_str"
    done
    
    printf "%s" "$ascii_str"
    ;;
    1)
    set -- '
    local i_S1 ascii_str_S1 tmp_str_S1
    for ((i_S1=0;i_S1<${#S1};i_S1++)) ; do
        ascii_str_S1+=${ascii_str_S1:+ }
        printf -v tmp_str_S1 "%x" "'\''${S1:i_S1:1}"
        ascii_str_S1+="$tmp_str_S1"
    done
    S1="$ascii_str_S1"
    ' "$@"
    eval -- "${1//S1/$2}"
    ;;
    *)
    local script_$1='
    local i_A1 ascii_str_A1 tmp_str_A1
    for ((i_A1=0;i_A1<${#3};i_A1++)) ; do
        ascii_str_A1+=${ascii_str_A1:+ }
        printf -v tmp_str_A1 "%x" "'\''${3:i_A1:1}"
        ascii_str_A1+="$tmp_str_A1"
    done
    eval -- A1[\$2]=\$ascii_str_A1
    '
    eval -- eval -- '"${script_'$1'//A1/$1}"'
    ;;
    esac
}

return 0

