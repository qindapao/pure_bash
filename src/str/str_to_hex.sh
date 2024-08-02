. ./meta/meta.sh
((DEFENSE_VARIABLES[str_to_hex]++)) && return 0

. ./str/str_ltrim_zeros.sh || return 1
. ./str/str_is_uint.sh || return 1

str_to_hex ()
{
    local in_str=$2
    
    str_is_uint_s "$in_str" || return
    str_ltrim_zeros_s "$in_str" in_str
    printf "0x%x" "$in_str" 
}

alias str_to_hex_s='str_to_hex ""'

return 0

