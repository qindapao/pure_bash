. ./meta/meta.sh
((DEFENSE_VARIABLES[json_base64_pack]++)) && return 0

. ./base64/base64_encode.sh || return 1
. ./json/json_common.sh || return 1

# 一个数据结构打包成base64字符串
# 1: 需要打包的数据结构
# 2: 打包后返回的字符串
json_base64_pack ()
{
    local -n _json_base64_pack_{json_ref=$1,out_str=$2}
    local _json_base64_pack_obj_name=${3:-${JSON_COMMON_MAGIC_STR}2}
    local _json_base64_pack_{attribute_all=,base64_str=,other_str=}

    _json_base64_pack_attribute_all="${_json_base64_pack_json_ref[@]@A}"
    if [[ "$_json_base64_pack_attribute_all" =~ ^(declare)\ ([^\ ]+)\ ([^\ =]+=)(.*) ]] ; then
        base64_encode _json_base64_pack_base64_str "${BASH_REMATCH[4]}"
        _json_base64_pack_other_str="${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${_json_base64_pack_obj_name}="
        _json_base64_pack_out_str="${_json_base64_pack_other_str}${_json_base64_pack_base64_str}"
    else
        # 普通字符串不打包成base64
        _json_base64_pack_out_str="$_json_base64_pack_attribute_all"
    fi
}

return 0

