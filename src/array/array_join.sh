. ./meta/meta.sh
((DEFENSE_VARIABLES[array_join]++)) && return 0

# 把数组通过分隔符链接成一个字符串
# :TODO: 和str_join重复?
array_join ()
{
    local separator="${1}"
    local array_e='' out_str=''
    # 要去掉1个参数要从2开始,而不是1
    for array_e in "${@:2}" ; do
        # 如果out_str有值,就填充$separator,否则就是空
        out_str+="${out_str:+$separator}${array_e}"
    done
    printf "%s" "$out_str"
}

return 0

