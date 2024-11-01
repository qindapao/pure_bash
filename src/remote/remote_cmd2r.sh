. ./meta/meta.sh
((DEFENSE_VARIABLES[remote_cmd2r]++)) && return 0

. ./str/str_quote.sh || return 1
. ./cntr/cntr_map.sh || return 1

# :TODO: 当前不支持免密的场景
# 后续的升级策略可以这样:
#   在函数第一次执行的时候可以测试下对端host是否是免密登录,
#   测试可以用这个函数发送一个退出码为0,但是有输出的命令,如果退出码是0,但是
#   没有捕捉到输出,那么证明是免密场景,或者用其它方法来测试
#   如果是,记录到一个全局表中,后续所有这个IP的登录都按照免密登录
#   处理,然后免密登录的exp脚本单独开发一个,保证和这个函数的输入输出契合
#   免密登录需要一开始就开启日志,然后删除一些干扰消息即可
# 免密的场景下没有任何输出
# 发送一个带参数的命令到远程主机
# 5: 如果发送的命令有复杂的参数那么最好引用起来
#    但是如果只是简单参数并且需要进行重定向等等操作,不要引用
remote_cmd2r ()
{
    local host=$1 timeout=$2 username=$3 password=$4 is_need_quote=$5
    shift 5
    local cmds=("${@}")
    ((is_need_quote)) && cntr_map cmds str_quote
    local tmp_file=$(mktemp)
    local ret=0

    cmd2r.exp "$host" "$timeout" "$username" "$password" "${cmds[@]}" > "$tmp_file"
    ret=$?
    {
    dos2unix "$tmp_file"
    dos2unix -f "$tmp_file"
    sed -i '1d' "$tmp_file"
    } &>/dev/null
    cat "$tmp_file" 2>/dev/null
    rm -f "$tmp_file" &>/dev/null
    return $ret
}

return 0

