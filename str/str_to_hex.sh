. ./meta/meta.sh
((DEFENSE_VARIABLES[str_to_hex]++)) && return 0

. ./str/str_trim_zeros.sh || return 1

str_to_hex ()
{
    local in_str="${1}"
    
    str_is_num "$in_str" || return

    in_str=$(str_trim_zeros "$in_str")
    printf "0x%x" "$in_str" 
}

return 0

