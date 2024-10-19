. ./meta/meta.sh
((DEFENSE_VARIABLES[json_awk_load]++)) && return 0

. ./json/json_common.sh || return 1
. ./json/json_overlay.sh || return 1
. ./awk/awk_json.sh || return 1


json_awk_load ()
{
    local -n _json_awk_load_json_ref=$1
    local _json_awk_load_json_in_file=$2
    local _json_awk_load_json_out_file="${2%.*}_out.txt"
    local -a _json_awk_load_json_array=()
    local _json_awk_load_item
    local _json_awk_load_json_key _json_awk_load_json_key_tmp
    local -a _json_awk_load_json_key_array=()

    awk_json_files "$_json_awk_load_json_out_file" "$_json_awk_load_json_in_file"
    mapfile -t _json_awk_load_json_array < "$_json_awk_load_json_out_file"

    for _json_awk_load_item in "${_json_awk_load_json_array[@]}" ; do
        if [[ "$_json_awk_load_item" =~ ^\[(([0-9]+,|\"([^\"]|\\\")*\",)*([0-9]+|\"([^\"]|\\\")*\"))\]$'\t'(.*)$ ]] ; then
            unset _json_awk_load_json_value ; local _json_awk_load_json_value
            _json_awk_load_json_value="${BASH_REMATCH[-1]}"
            awk_json_value_deal _json_awk_load_json_value
            if [[ "$_json_awk_load_json_value" == '[]' ]] ; then
                unset _json_awk_load_json_value ; local -a _json_awk_load_json_value=()
            elif [[ "$_json_awk_load_json_value" == '{}' ]] ; then
                unset _json_awk_load_json_value ; local -A _json_awk_load_json_value=()
            fi

            _json_awk_load_json_key="${BASH_REMATCH[1]}"
            _json_awk_load_json_key_array=()
            while [[ "$_json_awk_load_json_key" =~ ^([0-9]+,|\"([^\"]|\\\")*\",)(.+)$ ]] ||
                  [[ "$_json_awk_load_json_key" =~ ^([0-9]+|\"([^\"]|\\\")*\")$  ]] ; do
                _json_awk_load_json_key="${BASH_REMATCH[3]}"
                _json_awk_load_json_key_tmp="${BASH_REMATCH[1]}"

                if [[ ',' == "${_json_awk_load_json_key_tmp: -1:1}" ]] ; then
                    # 去掉逗号
                    _json_awk_load_json_key_tmp="${_json_awk_load_json_key_tmp:0:-1}"
                fi

                if [[ "$_json_awk_load_json_key_tmp" == \"*\" ]] ; then
                    # 字典键
                    awk_json_value_deal _json_awk_load_json_key_tmp
                    _json_awk_load_json_key_array+=("[${_json_awk_load_json_key_tmp}]")
                else
                    # 数组索引
                    _json_awk_load_json_key_array+=("$_json_awk_load_json_key_tmp")
                fi
            done
            
            # 设置数据结构的值(都按照字符串设置),默认情况下不要第一个顶级键
            json_overlay _json_awk_load_json_ref _json_awk_load_json_value "${_json_awk_load_json_key_array[@]:1}"
        fi
    done

    # :TODO: 暂时没有进行错误处理
    return ${JSON_COMMON_ERR_DEFINE[ok]}
}

return 0

