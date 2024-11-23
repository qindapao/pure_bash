. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_dec_to_ld]++)) && return 0

. ./str/str_ltrim_zeros.sh || return 1

# 10进制的数据转换成小端字节序
bit_dec_to_ld ()
{
    case "$#" in
    0)
    local value=
    IFS= read -d '' -r value || true
    str_ltrim_zeros value
    local little_endian i
    printf -v value "%x" "$value"

    for ((i=${#value};i>0;i-=2)) ; do
        little_endian+=${little_endian:+ }
        ((i<2)) && little_endian+=${value:0:1} || little_endian+=${value:i-2:2}
    done
    
    printf "%s" "$little_endian"
    ;;
    1)
    set -- '
    str_ltrim_zeros S1
    local little_endian_S1 i_S1
    printf -v S1 "%x" "$S1"

    for((i_S1=${#S1};i_S1>0;i_S1-=2)) ; do
        little_endian_S1+=${little_endian_S1:+ }
        ((i_S1<2)) && little_endian_S1+=${S1:0:1} || little_endian_S1+=${S1:i_S1-2:2}
    done
    S1=${little_endian_S1}
    ' "$@"
    eval -- "${1//S1/$2}"
    ;;
    *)
    local script_$1='
    local tmp_A1="$3"
    str_ltrim_zeros "tmp_A1"
    local little_endian_A1 i_A1
    printf -v tmp_A1 "%x" "$tmp_A1"

    for((i_A1=${#tmp_A1};i_A1>0;i_A1-=2)) ; do
        little_endian_A1+=${little_endian_A1:+ }
        ((i_A1<2)) && little_endian_A1+=${tmp_A1:0:1} || little_endian_A1+=${tmp_A1:i_A1-2:2}
    done
    eval -- A1[\$2]=\$little_endian_A1
    '
    eval -- eval -- '"${script_'$1'//A1/$1}"'
    ;;
    esac
}

return 0

