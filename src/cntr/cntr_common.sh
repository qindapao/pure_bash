. ./meta/meta.sh
((DEFENSE_VARIABLES[cntr_common]++)) && return 0

. ./array/array_is_array.sh || return 1
. ./dict/dict_is_dict.sh || return 1

CNTR_TEMPLATE_CHEKC_TYPE='
    local a_typeNAME
    if array_is_array "$1" ; then
        local -a aNAME=()
        a_typeNAME=0
    elif dict_is_dict "$1" ; then
        local -A aNAME=()
        a_typeNAME=1
    else
        return 1
    fi
'

CNTR_TEMPLATE_GENERATE_TEMP_FUNC_BEFORE='
    local -i is_blockNAME=0
    if [[ "$2" == *'\''$'\''* ]] ; then
        is_blockNAME=1
        _cntr_temp_funcNAME() { '

CNTR_TEMPLATE_GENERATE_TEMP_FUNC_AFTER=' ; }
        set -- "$1" "_cntr_temp_funcNAME" "${@:3}"
    fi
'

CNTR_TEMPLATE_DEL_TEMP_FUNC='
    ((is_blockNAME)) && unset -f _cntr_temp_funcNAME
'

return 0

