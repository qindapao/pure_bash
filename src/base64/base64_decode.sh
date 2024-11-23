. ./meta/meta.sh
((DEFENSE_VARIABLES[base64_decode]++)) && return 0

. ./base64/base64_common.sh || return 1

# :TODO: 因为ibash64保存到变量的功能不支持bash4.4暂时兼容
# :TODO: ibase64的实现有点问题 KFswXT0ieHhvbyIgWzFdPSJjY2NjY2NjY2NjY2NjY2MiKQ==
#        像这种包含等号的字符串后面再跟字符串已经无法识别
# :TODO: 并且ibase64这个工具还会多打印一个换行符出来，所以也需要处理
#
#        root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/src/tools# ibase64  -v str decode "${str1}IA=="
#        root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/src/tools# declare -p str
#        declare -- str="([0]=\"xxoo\" [1]=\"ccccccccccccccc\")"
#        root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/src/tools# 
#
#        但是系统自带的base64工具就没这个问题
#        root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/src/tools# echo -n "${str1}IA==" | base64 -d
#        ([0]="xxoo" [1]="ccccccccccccccc") root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/src/tools# echo -n "${str1}" | base64 -d                                 
#        ([0]="xxoo" [1]="ccccccccccccccc")root@DESKTOP-0KALMAH:/mnt/d/my_code/pure_bash/src/tools# 

# Base64 解码
if ((BASE64_USE_BUILTIN_TOOL)) ; then
    if ((__META_BASH_VERSION<=4004023)) ; then
        base64_decode ()
        {
            local decode_str
            # 工具会多打印一个换行符出来
            eval $1='$(ibase64 decode "$2" | { IFS= read -r -d "" decode_str || true ; decode_str=${decode_str%?} ;decode_str+=" " ; printf "%s" "${decode_str}" ; })'
            printf -v "$1" "%s" "${!1%?}"
        }
    else
        base64_decode ()
        {
            ibase64 -v "$1" decode "$2"
        }
    fi
else
    base64_decode () 
    { 
        printf -v "$1" "%s" "$(printf "%s" "${2}IA==" | base64 -d)"
        printf -v "$1" "%s" "${!1%?}"
    }
fi

return 0

