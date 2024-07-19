. ./meta/meta.sh
((DEFENSE_VARIABLES[atom_ifs]++)) && return 0

alias atom_ifs_cn_set="declare OLD_IFS=\"\$IFS\" ; declare IFS=\$'\n' ;"
alias atom_ifs_recover="IFS=\"\$OLD_IFS\" ;"

return 0

