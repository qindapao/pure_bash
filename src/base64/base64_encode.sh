. ./meta/meta.sh
((DEFENSE_VARIABLES[base64_encode]++)) && return 0

. ./base64/base64_common.sh || return 1

# Base64 编码
if ((BASE64_USE_BUILTIN_TOOL)) ; then
base64_encode ()
{
    ibase64 -v "$1" encode "$2"
}
else
base64_encode ()
{
    printf -v "$1" "%s" "$(printf "%s" "$2" | base64 -w 0)"
}
fi

return 0

