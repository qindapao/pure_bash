. ./meta/meta.sh
((DEFENSE_VARIABLES[date_vars]++)) && return 0

. ./atom/atom_get_bash_version.sh || return 1

atom_get_bash_version __date_vars_bash_major_version __date_vars_bash_minor_version

return 0

