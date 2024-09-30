. ./meta/meta.sh
((DEFENSE_VARIABLES[base64_decode]++)) && return 0

. ./base64/base64_common.sh || return 1

# Base64 解码
if ((BASE64_USE_BUILTIN_TOOL)) ; then
base64_decode ()
{
    ibase64 -v "$1" decode "$2"
}
else
base64_decode () 
{ 
    printf -v "$1" "%s" "$(printf "%s" "${2}IA==" | base64 -d)"
    printf -v "$1" "%s" "${!1%?}"
}
fi

return 0

