. ./meta/meta.sh
((DEFENSE_VARIABLES[bit_hex_to_dec]++)) && return 0

# 16进制转换成10进制(传进来的16进制可能没有0x)
# 0Xab102 0x456 005678
# 可用于高阶函数cntr_map
bit_hex_to_dec ()
{
    case "$#" in
    0)
    local value=
    IFS= read -d '' -r value || true
    value=${value,,}
    [[ "$value" != "0x"* ]] && value="0x${value}"
    printf "%d" "$value"
    ;;
    1)
    eval -- ''$1'=${!1,,}'
    [[ "${!1}" != "0x"* ]] && eval -- ''$1'="0x${!1}"'
    printf -v "$1" "%d" "${!1}"
    ;;
    *)
    set -- '
        shift
        eA1=${3,,}
        [[ "$eA1" != "0x"* ]] && eA1="0x${eA1}"
        printf -v eA1 "%d" "${eA1}"
        A1[$2]=${eA1}
    ' "${@}"
    eval -- "${1//A1/$2}"
    ;;
    esac
}

return 0

