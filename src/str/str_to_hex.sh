. ./meta/meta.sh
((DEFENSE_VARIABLES[str_to_hex]++)) && return 0

. ./str/str_trim_zeros.sh || return 1
. ./str/str_is_num.sh || return 1

str_to_hex ()
{
    local in_str=$2
    
    str_is_num_s "$in_str" || return

    in_str=$(str_trim_zeros_s "$in_str")
    printf "0x%x" "$in_str" 
}

alias str_to_hex_s='str_to_hex ""'

return 0

